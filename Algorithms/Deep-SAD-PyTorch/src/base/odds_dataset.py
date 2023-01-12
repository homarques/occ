from pathlib import Path
from torch.utils.data import Dataset
from scipy.io import loadmat
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from torchvision.datasets.utils import download_url

import os
import torch
import numpy as np


class ODDSDataset(Dataset):
    """
    ODDSDataset class for datasets from Outlier Detection DataSets (ODDS): http://odds.cs.stonybrook.edu/

    Dataset class with additional targets for the semi-supervised setting and modification of __getitem__ method
    to also return the semi-supervised target as well as the index of a data sample.
    """

    def __init__(self, train, data, scaler, minmax_scaler):
        super(Dataset, self).__init__()

        self.classes = [0, 1]
        self.train = train  # training set or test set

        X = data
        y = np.uint8([0] * X.shape[0])

        if self.train:
            # Standardize data (per feature Z-normalization, i.e. zero-mean and unit variance)
            self.scaler = StandardScaler().fit(X)
            X_train_stand = self.scaler.transform(X)

            # Scale to range [0,1]
            self.minmax_scaler = MinMaxScaler().fit(X_train_stand)
            X_train_scaled = self.minmax_scaler.transform(X_train_stand)

            self.data = torch.tensor(X_train_scaled, dtype=torch.float32)
            self.targets = torch.tensor(y, dtype=torch.int64)
        else:
            # Standardize data (per feature Z-normalization, i.e. zero-mean and unit variance)
            X_test_stand = scaler.transform(X)

            # Scale to range [0,1]
            X_test_scaled = minmax_scaler.transform(X_test_stand)

            self.data = torch.tensor(X_test_scaled, dtype=torch.float32)
            self.targets = torch.tensor(y, dtype=torch.int64)

        self.semi_targets = torch.zeros_like(self.targets)

    def __getitem__(self, index):
        """
        Args:
            index (int): Index

        Returns:
            tuple: (sample, target, semi_target, index)
        """
        sample, target, semi_target = self.data[index], int(self.targets[index]), int(self.semi_targets[index])

        return sample, target, semi_target, index

    def __len__(self):
        return len(self.data)
