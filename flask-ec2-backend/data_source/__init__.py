# Export mock or real data_source, always aliased with the same generic name

# from data_source.mock import MockUserDataSource as UserDataSource
# from data_source.mock import MockPhotoDataSource as PhotoDataSource

from data_source.aws import AwsUserDataSource as UserDataSource
from data_source.aws import AwsPhotoDataSource as PhotoDataSource

from data_source.interface import IUserDataSource, IPhotoDataSource
