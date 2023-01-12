from torch.utils.data import DataLoader, Subset
from base.base_dataset import BaseADDataset
from base.odds_dataset import ODDSDataset

import torch


class ODDSADDataset(BaseADDataset):

    def __init__(self, data, train, scaler, minmax_scaler):

        # Define normal and outlier classes
        self.n_classes = 2  # 0: normal, 1: outlier
        self.normal_classes = (0,)
        self.outlier_classes = (1,)

        if(train):
            # Get train set
            self.train_set = ODDSDataset(train = True, data = data, scaler = None, minmax_scaler = None)
            self.test_set = None
        else:
            # Get test set
            self.test_set = ODDSDataset(train = False, data = data, scaler = scaler, minmax_scaler = minmax_scaler)
            self.train_set = self.test_set

    def loaders(self, batch_size: int, shuffle_train=True, shuffle_test=False, num_workers: int = 0) -> (
            DataLoader, DataLoader):
        train_loader = DataLoader(dataset=self.train_set, batch_size=batch_size, shuffle=shuffle_train,
                                  num_workers=num_workers, drop_last=True)
        test_loader = DataLoader(dataset=self.test_set, batch_size=batch_size, shuffle=shuffle_test,
                                 num_workers=num_workers, drop_last=False)
        return train_loader, test_loader
