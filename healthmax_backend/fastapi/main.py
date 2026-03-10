import models, schemas
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from passlib.context import CryptContext
from database import get_db
from typing import List

app = FastAPI(title="HealthMax API")

# 密码哈希上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# ---------- 用户注册 ----------

@app.post('/register', response_model=schemas.UserResponse)
async def register(user: schemas.UserCreate, db: AsyncSession = Depends(get_db)):
    try:
        # 原来的所有代码（包括检查用户是否存在、创建用户等）
        result = await db.execute(select(models.User).where(models.User.username == user.username))
        existing_user = result.scalar_one_or_none()
        if existing_user:
            raise HTTPException(status_code=400, detail="用户名已存在")
        # ... 创建用户 ...
    except Exception as e:
        import traceback
        traceback.print_exc()   # 在终端打印完整堆栈
        raise HTTPException(status_code=500, detail=str(e))  # 返回具体错误信息

    # 2. 密码哈希并创建新用户
    hashed_password = get_password_hash(user.password)
    db_user = models.User(
        username=user.username,
        password_hash=hashed_password,
        gender=user.gender,
        age=user.age,
        height_cm=user.height_cm,
        weight_kg=user.weight_kg
    )
    db.add(db_user)
    await db.commit()
    await db.refresh(db_user)
    return db_user

# ---------- 登录（简单版） ----------
@app.post('/login')
async def login(username: str, password: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(models.User).where(models.User.username == username))
    user = result.scalar_one_or_none()          # 注意：这里变量名是 result 不是 results
    if not user or not verify_password(password, user.password_hash):
        raise HTTPException(status_code=401, detail="用户名或密码错误")
    return {"message": "登录成功", "username": user.username}

# ---------- 健康日志模块 ----------
@app.post("/users/{username}/health-logs", response_model=schemas.HealthLogResponse)
async def create_health_log(
    username: str,
    log: schemas.HealthLogCreate,
    db: AsyncSession = Depends(get_db)
):
    # 确保用户存在
    user = await db.get(models.User, username)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    db_log = models.HealthLog(
        username=username,
        metric_type=log.metric_type,
        value=log.value
    )
    db.add(db_log)
    await db.commit()
    await db.refresh(db_log)
    return db_log

@app.get("/users/{username}/health-logs", response_model=List[schemas.HealthLogResponse])
async def get_health_logs(
    username: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(models.HealthLog)
        .where(models.HealthLog.username == username)
        .offset(skip)
        .limit(limit)
    )
    logs = result.scalars().all()
    return logs

# ---------- 饮食日志模块 ----------
@app.post("/users/{username}/food-logs", response_model=schemas.FoodLogResponse)
async def create_food_log(
    username: str,
    log: schemas.FoodLogCreate,
    db: AsyncSession = Depends(get_db)
):
    user = await db.get(models.User, username)
    if not user:
        raise HTTPException(status_code=404, detail="用户不存在")
    
    db_log = models.FoodLog(
        username=username,
        food_name=log.food_name,
        calories=log.calories
    )
    db.add(db_log)
    await db.commit()
    await db.refresh(db_log)
    return db_log

@app.get("/users/{username}/food-logs", response_model=List[schemas.FoodLogResponse])
async def get_food_logs(
    username: str,
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(models.FoodLog)
        .where(models.FoodLog.username == username)
        .offset(skip)
        .limit(limit)
    )
    logs = result.scalars().all()
    return logs

# 其他模块（目标、设备、医院反馈等）可类似添加