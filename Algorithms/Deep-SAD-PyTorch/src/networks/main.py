from .mnist_LeNet import MNIST_LeNet, MNIST_LeNet_Autoencoder
from .fmnist_LeNet import FashionMNIST_LeNet, FashionMNIST_LeNet_Autoencoder
from .cifar10_LeNet import CIFAR10_LeNet, CIFAR10_LeNet_Autoencoder
from .mlp import MLP, MLP_Autoencoder
from .vae import VariationalAutoencoder
from .dgm import DeepGenerativeModel, StackedDeepGenerativeModel


def build_network(dim, N, ae_net=None):
    """Builds the neural network."""

    net = None
    net = MLP(x_dim=dim, h_dims=[N, int(N/2)], rep_dim=max(int(min(N/4,dim-2)),1), bias=False)

    return net


def build_autoencoder(dim, N):
    """Builds the corresponding autoencoder network."""

    ae_net = None
    ae_net = MLP_Autoencoder(x_dim=dim, h_dims=[N, int(N/2)], rep_dim=max(int(min(N/4,dim-2)),1), bias=False)

    return ae_net
