from .odds import ODDSADDataset


def load_dataset(data, train, scaler, minmax_scaler):
    """Loads the dataset."""

    dataset = None
    dataset = ODDSADDataset(data, train, scaler, minmax_scaler)

    return dataset
