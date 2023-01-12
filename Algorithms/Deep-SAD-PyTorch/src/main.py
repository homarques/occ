import torch

from DeepSAD import DeepSAD
from datasets.main import load_dataset
from base.odds_dataset import ODDSDataset
import numpy as np
import random

def predict(deepSAD, data, data_size, latent_size):
    data = np.array(data)
    data_size = int(data_size)
    latent_size = int(latent_size)
    data = data.reshape(latent_size, data_size).T

    dataset = load_dataset(data = data, train = False, scaler = deepSAD.scaler, minmax_scaler = deepSAD.minmax_scaler)
    dataset.test_set = ODDSDataset(train = False, data = data, scaler = deepSAD.scaler, minmax_scaler = deepSAD.minmax_scaler)

    # Default device to 'cpu' if cuda is not available
    if not torch.cuda.is_available():
        device = 'cpu'

    # Test model
    deepSAD.test(dataset, device=device, n_jobs_dataloader=0)
    return deepSAD.results['test_scores']


def start(data, data_size, latent_size, N):
    """
    Deep SAD, a method for deep semi-supervised anomaly detection.

    """
    random.seed(1)
    np.random.seed(1)
    torch.manual_seed(1)
    torch.cuda.manual_seed(1)
    torch.backends.cudnn.deterministic = True

    data = np.array(data)
    data_size = int(data_size)
    latent_size = int(latent_size)
    N = int(N)
    data = data.reshape(latent_size, data_size).T

    eta = 1
    optimizer_name = ae_optimizer_name = 'adam'
    lr = ae_lr = 0.001
    n_epochs = ae_n_epochs = 150
    lr_milestone = ae_lr_milestone = [50]
    batch_size = ae_batch_size = min(100, data_size)
    weight_decay = ae_weight_decay = 0.5e-6

    num_threads = 0

    # Default device to 'cpu' if cuda is not available
    if not torch.cuda.is_available():
        device = 'cpu'
    # Set the number of threads used for parallelizing CPU operations
    if num_threads > 0:
        torch.set_num_threads(num_threads)

    # Load data
    dataset = load_dataset(data, train = True, scaler = None, minmax_scaler = None)

    # Initialize DeepSAD model and set neural network phi
    deepSAD = DeepSAD(eta)
    deepSAD.set_network(latent_size, N)

    # # Train model on dataset
    deepSAD.train(dataset, optimizer_name = optimizer_name, lr = lr, 
                  n_epochs = n_epochs, lr_milestones = lr_milestone, 
                  batch_size = batch_size, weight_decay = weight_decay, 
                  device = device, n_jobs_dataloader = 0)

    return deepSAD

