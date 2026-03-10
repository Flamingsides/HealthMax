import asyncio
import asyncpg

async def test():
    conn = await asyncpg.connect(
        user='chunnanzhang',
        password='',   # 无密码留空
        database='HealthMaxDB',
        host='localhost',
        port=5432
    )
    await conn.execute('SELECT 1')
    await conn.close()
    print("数据库连接成功！")

asyncio.run(test())