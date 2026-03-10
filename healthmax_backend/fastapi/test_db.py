import asyncio
from sqlalchemy.ext.asyncio import create_async_engine

DATABASE_URL = "postgresql+asyncpg://你的用户名:你的密码@localhost:5432/HealthMaxDB"

async def test():
    engine = create_async_engine(DATABASE_URL)
    async with engine.connect() as conn:
        await conn.execute("SELECT 1")
    print("数据库连接成功！")

asyncio.run(test())