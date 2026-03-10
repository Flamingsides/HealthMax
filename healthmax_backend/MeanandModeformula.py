
import pandas as pd
from typing import List, Optional, Any


def parameters(file: str, col: int, row_start: int, row_end: int) -> pd.Series:
    df = pd.read_csv(file)
    col_idx = col - 1
    row_start_idx = row_start - 1
    row_end_idx = row_end  # iloc stop is exclusive, so keep as-is

    if col_idx < 0 or col_idx >= df.shape[1]:
        raise IndexError(f"column {col} out of range (file has {df.shape[1]} columns)")
    if row_start_idx < 0 or row_start_idx >= df.shape[0]:
        raise IndexError(f"start row {row_start} out of range (data has {df.shape[0]} rows)")
    if row_end_idx <= row_start_idx or row_end_idx > df.shape[0]:
        raise IndexError(f"end row {row_end} out of range or <= start row")

    return df.iloc[row_start_idx:row_end_idx, col_idx]

def mean(file: str, col_1based: int, row_start_1based: int, row_end_1based: int) -> Optional[float]:

    series = parameters(file, col_1based, row_start_1based, row_end_1based)
    numeric = pd.to_numeric(series, errors="coerce").dropna()
    if numeric.empty:
        return None
    return float(numeric.mean())

def mode(file: str, col_1based: int, row_start_1based: int, row_end_1based: int) -> List[Any]:

    series = parameters(file, col_1based, row_start_1based, row_end_1based)
    numeric = pd.to_numeric(series, errors="coerce").dropna()
    if numeric.empty:
        return []
    return numeric.mode().tolist()

#Example on how to use!!!
mean_val = mean("testing.csv", 10 , 1, 10)   # 2nd column, rows 1–10
print("Mean:", mean_val)

modes = mode("testing.csv", 10, 1, 10)
print("Mode(s):", modes)


import pandas as pd
from typing import List, Optional, Any

def _to_numeric(series: pd.Series) -> pd.Series:
    return pd.to_numeric(series, errors="coerce").dropna()

def _week_of_month(dt: pd.Timestamp) -> int:
    first = dt.replace(day=1)
    dom = dt.day
    adjusted = dom + first.weekday()
    return (adjusted - 1) // 7 + 1

def daily_values(
    file: str,
    date_col_1based: int,
    value_col_1based: int,
    target_year: Optional[int] = None,
    target_month: Optional[int] = None,
    kind: str = "mean",  # "mean" or "mode"
) -> List[Any]:
    df = pd.read_csv(file)
    d_idx = date_col_1based - 1
    v_idx = value_col_1based - 1
    if d_idx < 0 or d_idx >= df.shape[1]:
        raise IndexError("date column out of range")
    if v_idx < 0 or v_idx >= df.shape[1]:
        raise IndexError("value column out of range")

    # create a dedicated datetime column to guarantee .dt works
    df["_date"] = pd.to_datetime(df.iloc[:, d_idx], errors="coerce")
    df = df.dropna(subset=["_date"])
    if target_year is not None:
        df = df[df["_date"].dt.year == target_year]
    if target_month is not None:
        df = df[df["_date"].dt.month == target_month]

    results: List[Any] = []
    for wd in range(7):  # 0=Mon .. 6=Sun
        group = df[df["_date"].dt.weekday == wd].iloc[:, v_idx]
        numeric = _to_numeric(group)
        if kind == "mean":
            results.append(float(numeric.mean()) if not numeric.empty else None)
        elif kind == "mode":
            results.append(numeric.mode().tolist() if not numeric.empty else [])
        else:
            raise ValueError('kind must be "mean" or "mode"')
    return results

def weekly_values(
    file: str,
    date_col_1based: int,
    value_col_1based: int,
    target_year: int,
    target_month: int,
    week_in_month: int,
    kind: str = "mean",
) -> List[Any]:
    df = pd.read_csv(file)
    d_idx = date_col_1based - 1
    v_idx = value_col_1based - 1
    if d_idx < 0 or d_idx >= df.shape[1]:
        raise IndexError("date column out of range")
    if v_idx < 0 or v_idx >= df.shape[1]:
        raise IndexError("value column out of range")

    df["_date"] = pd.to_datetime(df.iloc[:, d_idx], errors="coerce")
    df = df.dropna(subset=["_date"])
    df = df[(df["_date"].dt.year == target_year) & (df["_date"].dt.month == target_month)]
    if df.empty:
        return [None if kind == "mean" else [] for _ in range(7)]

    df["_week_of_month"] = df["_date"].apply(_week_of_month)
    results: List[Any] = []
    for wd in range(7):
        group = df[(df["_week_of_month"] == week_in_month) & (df["_date"].dt.weekday == wd)].iloc[:, v_idx]
        numeric = _to_numeric(group)
        if kind == "mean":
            results.append(float(numeric.mean()) if not numeric.empty else None)
        else:
            results.append(numeric.mode().tolist() if not numeric.empty else [])
    return results

def monthly_values(
    file: str,
    date_col_1based: int,
    value_col_1based: int,
    target_year: int,
    target_month: int,
    kind: str = "mean",
) -> List[Any]:
    df = pd.read_csv(file)
    d_idx = date_col_1based - 1
    v_idx = value_col_1based - 1
    if d_idx < 0 or d_idx >= df.shape[1]:
        raise IndexError("date column out of range")
    if v_idx < 0 or v_idx >= df.shape[1]:
        raise IndexError("value column out of range")

    df["_date"] = pd.to_datetime(df.iloc[:, d_idx], errors="coerce")
    df = df.dropna(subset=["_date"])
    df = df[(df["_date"].dt.year == target_year) & (df["_date"].dt.month == target_month)]
    numeric = _to_numeric(df.iloc[:, v_idx])
    if kind == "mean":
        return [float(numeric.mean())] if not numeric.empty else [None]
    else:
        return numeric.mode().tolist() if not numeric.empty else []

#Example on how to use!!!!!
daily_means = daily_values("testing.csv", date_col_1based=7, value_col_1based=10, target_year=2026, target_month=2, kind="mean")
print(daily_means)


weekly_modes = weekly_values("testing.csv", date_col_1based=7, value_col_1based=10, target_year=2026, target_month=2, week_in_month=2, kind="mode")
print(weekly_modes)  # [modes_Mon, modes_Tue, ..., modes_Sun]

# Monthly mean for February 2026
monthly_mean = monthly_values("testing.csv", date_col_1based=7, value_col_1based=10, target_year=2026, target_month=2, kind="mean")
print(monthly_mean)  # [mean_for_month] or [None]
