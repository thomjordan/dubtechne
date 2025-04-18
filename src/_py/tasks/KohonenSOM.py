import librosa
import numpy as np
import librosa.display
from minisom import MiniSom
import os
from scipy.spatial.distance import euclidean
from fastdtw import fastdtw

use_dtw = True 

def compute_features(audio_file, sr=44100, n_fft=1024, hop_length=512, num_segments=5):
    # Load audio file
    y, sr = librosa.load(audio_file, sr=sr)
    
    # Compute STFT
    S = np.abs(librosa.stft(y, n_fft=n_fft, hop_length=hop_length))
    
    # Compute feature matrices per spectral frame
    spectral_centroid = librosa.feature.spectral_centroid(S=S, sr=sr)
    spectral_flux = np.sqrt(np.sum(np.diff(S, axis=1) ** 2, axis=0))
    spectral_kurtosis = librosa.feature.spectral_bandwidth(S=S, sr=sr, p=4)  # Approximate kurtosis
    
    # Handle NaN and Inf values by replacing them with zeros
    spectral_centroid = np.nan_to_num(spectral_centroid, nan=0.0, posinf=0.0, neginf=0.0)
    spectral_flux = np.nan_to_num(spectral_flux, nan=0.0, posinf=0.0, neginf=0.0)
    spectral_kurtosis = np.nan_to_num(spectral_kurtosis, nan=0.0, posinf=0.0, neginf=0.0)
    
    # Ensure all features have the same number of frames
    num_frames = max(spectral_centroid.shape[1], spectral_flux.shape[0], spectral_kurtosis.shape[1])
    
    # Pad or truncate to match the number of frames
    spectral_centroid = np.pad(spectral_centroid, ((0, 0), (0, num_frames - spectral_centroid.shape[1])), mode='constant')
    spectral_flux = np.pad(spectral_flux, (0, num_frames - spectral_flux.shape[0]), mode='constant')
    spectral_kurtosis = np.pad(spectral_kurtosis, ((0, 0), (0, num_frames - spectral_kurtosis.shape[1])), mode='constant')
    
    # Stack features into one array
    features = np.vstack([spectral_centroid, spectral_flux, spectral_kurtosis])
    
    # Split features into time segments
    num_frames = features.shape[1]
    segment_size = num_frames // num_segments
    
    feature_vector = []
    segment_sequences = []
    for i in range(num_segments):
        start = i * segment_size
        end = (i + 1) * segment_size if i < num_segments - 1 else num_frames
        segment_features = features[:, start:end]
        
        # Compute mean and variance for each feature in the segment
        mean_vals = np.mean(segment_features, axis=1)
        var_vals = np.var(segment_features, axis=1)

        # Handle NaN and Inf values by replacing them with zeros
        mean_vals = np.nan_to_num(mean_vals, nan=0.0, posinf=0.0, neginf=0.0)
        var_vals = np.nan_to_num(var_vals, nan=0.0, posinf=0.0, neginf=0.0)
        
        feature_vector.extend(mean_vals)
        feature_vector.extend(var_vals)
        
        # Store feature sequence for DTW comparison
        segment_sequences.append(mean_vals)
    
    return np.array(feature_vector), np.array(segment_sequences)  # Final feature vector & sequence for DTW

def compute_dtw_matrix(feature_sequences):
    num_clips = len(feature_sequences)
    dtw_matrix = np.zeros((num_clips, num_clips))
    
    for i in range(num_clips):
        for j in range(i + 1, num_clips):
            distance, _ = fastdtw(feature_sequences[i], feature_sequences[j], dist=euclidean)
            dtw_matrix[i, j] = distance
            dtw_matrix[j, i] = distance  # Symmetric matrix
    
    return dtw_matrix


from sklearn.decomposition import PCA

def apply_pca(augmented_features, n_components=0.95):
    """
    Reduce the dimensionality of the augmented feature vectors using PCA.
    
    :param augmented_features: The feature matrix combining raw features and DTW distances.
    :param n_components: The number of principal components to keep, or explained variance ratio.
    :return: PCA-transformed feature matrix and the trained PCA model.
    """
    pca = PCA(n_components=n_components)  # Keep 95% of variance by default
    reduced_features = pca.fit_transform(augmented_features)
    print(f"PCA reduced feature dimensions from {augmented_features.shape[1]} to {reduced_features.shape[1]}")
    
    return reduced_features, pca


def train_som(feature_vectors, dtw_matrix, grid_size=(5, 5), sigma=1.0, learning_rate=0.5, num_iterations=1000):
    # Combine feature vectors with DTW distance information
    augmented_features = np.hstack((feature_vectors, dtw_matrix))
    
    # Apply PCA to reduce dimensionality
    if use_dtw:
        reduced_features, pca_model = apply_pca(augmented_features)
    else:
        reduced_features, pca_model = apply_pca(feature_vectors)

    # Initialize SOM with the reduced feature size
    som = MiniSom(grid_size[0], grid_size[1], reduced_features.shape[1], sigma=sigma, learning_rate=learning_rate)
    som.random_weights_init(reduced_features)

    # Train SOM with the reduced features
    som.train_random(reduced_features, num_iterations)

    return som, pca_model


def getStringForCurrentTimestamp():
    ts = time.time()
    return datetime.datetime.fromtimestamp(ts).strftime('%Y_%m_%d__%H_%M_%S') 


def cluster_audio_clips(directory):
    # Get all audio files in directory
    audio_files = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.wav')]
    
    # Compute feature vectors and sequences for DTW
    feature_vectors = []
    feature_sequences = []
    for file in audio_files:
        fv, seq = compute_features(file)
        feature_vectors.append(fv)
        feature_sequences.append(seq)
    
    feature_vectors = np.array(feature_vectors)
    
    # Compute DTW matrix
    dtw_matrix = compute_dtw_matrix(feature_sequences)

    # Train SOM with PCA-reduced features
    som, pca_model = train_som(feature_vectors, dtw_matrix)

    # Transform augmented features using the trained PCA model
    augmented_features = np.hstack((feature_vectors, dtw_matrix))

    if use_dtw:
        reduced_features = pca_model.transform(augmented_features)
    else:
        reduced_features = pca_model.transform(feature_vectors)

    # Assign each audio clip to a cluster using PCA-transformed features
    clusters = np.array([som.winner(fv) for fv in reduced_features])

    # Initialize a list to store cluster counts and their locations
    cluster_counts = {}

    # Assign each feature vector to a cluster
    for fv in reduced_features:
        winner_x, winner_y = som.winner(fv)  # Get the coordinates of the winning neuron
        cluster = (winner_x, winner_y)
        
        if cluster in cluster_counts:
            cluster_counts[cluster] += 1
        else:
            cluster_counts[cluster] = 1

    # Sort clusters by their (x, y) coordinates in ascending order
    sorted_clusters = sorted(cluster_counts.items(), key=lambda x: (x[0][0], x[0][1]))
    
    return clusters, audio_files, sorted_clusters


import pathlib
import time
import datetime

def setupDirectories(parent_dir):
    som_directory = os.path.join(directory, 'SOM')

    # if SOM directory doesn't exist, make it
    if not os.path.isdir(som_directory):    
        os.mkdir(som_directory)

    # if it does exist, archive contents into a new directory and clear the 'SOM' directory
    else:     
        som_previous_runs_directory = os.path.join(directory, 'SOM_previous_runs')
        if not os.path.isdir(som_previous_runs_directory):   # first check if the 'SOM_previous_runs' directory exists
            os.mkdir(som_previous_runs_directory)            # if it doesn't, make it

        # make new archive with current date:time for a name
        new_folder_name = getStringForCurrentTimestamp()
        path_to_new_folder = os.path.join(som_previous_runs_directory, new_folder_name)
        os.mkdir(path_to_new_folder) 

        # move contents to archive
        source_path = pathlib.Path(som_directory)
        dest_path = pathlib.Path(path_to_new_folder)
        for f in source_path.rglob("*"):
            f.rename(dest_path / f.name)


# Example usage
directory = 'samples/toms' 

# make sure directories exist, and archive results from previous runs
setupDirectories(directory)

clusters, audio_files, sorted_clusters = cluster_audio_clips(directory)
#sorted_clusters = list_cluster_locations(som, augmented_features)

# Print the cluster for each audio file, and make a symlink in corresponing directory
for file, cluster in zip(audio_files, clusters):
    # print(f"File: {file} -> Cluster: {cluster}")

    # store symlink to audio file in directory corresponding to cluster
    this_cluster_directory = os.path.join(directory, 'SOM', np.array2string(cluster, precision=0, separator=' ', suppress_small=True))

    if not os.path.isdir(this_cluster_directory): 
        os.mkdir(this_cluster_directory)

    _, file_name = os.path.split(file)
    absolute_file_path = os.path.abspath(file)
    pathname_of_symlink = os.path.join(this_cluster_directory, file_name)
    os.symlink(absolute_file_path, pathname_of_symlink) 


# Print the sorted clusters and their counts
for cluster, count in sorted_clusters:
    print(f"Cluster location: {cluster} -> Number of clips: {count}")





