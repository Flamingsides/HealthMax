from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional

# User 相关
class UserBase(BaseModel):
    username: str
    gender: Optional[str] = None
    age: Optional[int] = None
    height_cm: Optional[float] = None
    weight_kg: Optional[float] = None

class UserCreate(UserBase):
    password: str   # 原始密码，将在后端哈希

class UserResponse(UserBase):
    total_points: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

# HealthLog 相关
class HealthLogBase(BaseModel):
    metric_type: str
    value: float

class HealthLogCreate(HealthLogBase):
    pass

class HealthLogResponse(HealthLogBase):
    log_id: int
    username: str
    recorded_at: datetime

    model_config = ConfigDict(from_attributes=True)

# FoodLog 相关
class FoodLogBase(BaseModel):
    food_name: str
    calories: int

class FoodLogCreate(FoodLogBase):
    pass

class FoodLogResponse(FoodLogBase):
    log_id: int
    username: str
    logged_at: datetime

    model_config = ConfigDict(from_attributes=True)

# 其他表可按相同模式补充……