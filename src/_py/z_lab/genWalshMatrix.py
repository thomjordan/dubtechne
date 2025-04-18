import numpy as np
np.set_printoptions(threshold=4096)


'''
def hadamard_matrix(n):
    if n == 1:
        return np.array([[1]])
    else:
        H_n_1 = hadamard_matrix(n // 2)
        return np.block([
            [H_n_1, H_n_1],
            [H_n_1, -H_n_1]
        ])

def walsh_matrix(n):
    H = np.matrix(hadamard_matrix(n)).transpose()
    # Bit-reversal permutation
    bit_reversal = np.argsort([int(f'{i:0{n.bit_length()-1}b}'[::-1], 2) for i in range(n)])
    return H[bit_reversal]

if __name__ == "__main__":
    n = 16
    W = walsh_matrix(n)
    print(W)
'''


def walsh_matrix(n):
    """
    Generates a Walsh matrix of size n x n, where n is a power of 2.

    Args:
        n: The size of the matrix (must be a power of 2).

    Returns:
        A NumPy array representing the Walsh matrix.
    """

    if not (n > 0 and (n & (n - 1)) == 0):
        raise ValueError("n must be a power of 2")

    if n == 1:
        return np.array([[1]])

    half_n = n // 2
    H_half = walsh_matrix(half_n)
    H = np.vstack((
        np.hstack((H_half, H_half)),
        np.hstack((H_half, -H_half))
    ))
    return H

if __name__ == '__main__':
    size = 8
    walsh_matrix_8 = walsh_matrix(size)
    print(f"Walsh matrix of size {size}:\n{walsh_matrix_8}")

    size = 16
    walsh_matrix_16 = walsh_matrix(size)
    print(f"Walsh matrix of size {size}:\n{walsh_matrix_16}")

