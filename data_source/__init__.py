# Export mock or real data_source, always aliased with the same generic name
from data_source.mock import \
    MockUserDataSource as UserDataSource, \
    MockPhotoDataSource as PhotoDataSource
from data_source.interface import IUserDataSource, IPhotoDataSource
