import datetime

import databento as db
import pytest

from finm37000 import (
    get_all_legs_on,
    get_databento_api_key,
    temp_env,
)


@pytest.fixture
def client() -> db.Historical:
    with temp_env(DATABENTO_API_KEY=get_databento_api_key()):
        client = db.Historical()
    return client


@pytest.mark.db
def test_get_all_legs_on_with_delayed_settle(client: db.Historical) -> None:
    date = datetime.date(2022, 2, 24)
    crude_at_war, _ = get_all_legs_on(client, date, "CL.FUT")
    valid_prices = crude_at_war[crude_at_war["Settlement price"].notnull()]
    assert not valid_prices.empty
