import numpy as np

def cosine_similarity(A, B):
    """
    Calculate the cosine similarity between two vectors A and B.

    Parameters:
    A (array-like): First vector.
    B (array-like): Second vector.

    Returns:
    float: Cosine similarity between A and B.
    """
    A = np.array(A)
    B = np.array(B)

    dot_product = np.dot(A, B)
    norm_A = np.linalg.norm(A)
    norm_B = np.linalg.norm(B)

    if norm_A == 0 or norm_B == 0:
        return 0.0

    return dot_product / (norm_A * norm_B)


# Example usage
if __name__ == "__main__":
    A  = [1, 2, 3]
    B  = [4, 5, 6]
    A1 = [1, 0, 1, 0, 1, 0, 1, 0]
    B1 = [0, 1, 0, 1, 0, 1, 0, 1]
    C1 = [1, 1, 1, 1, 0, 0, 0, 0]
    D1 = [1, 1, 0, 0, 1, 1, 0, 0]
    E1 = [1, 0, 0, 1, 0, 0, 1, 0]
    print("Cosine Similarity:", cosine_similarity(A1, A1))
