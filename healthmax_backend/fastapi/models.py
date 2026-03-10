from sqlalchemy import Column, Integer, String, DECIMAL, TIMESTAMP, Text, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    username = Column(String(50), primary_key=True, index=True)
    password_hash = Column(String(255), nullable=False)
    gender = Column(String(10))
    age = Column(Integer)
    height_cm = Column(DECIMAL(5, 2))
    weight_kg = Column(DECIMAL(5, 2))
    total_points = Column(Integer, default=0)
    created_at = Column(TIMESTAMP, default=datetime.now)

    # 关系
    health_logs = relationship("HealthLog", back_populates="user")
    food_logs = relationship("FoodLog", back_populates="user")
    targets = relationship("UserTarget", back_populates="user")
    devices = relationship("ConnectedDevice", back_populates="user")
    feedbacks = relationship("HospitalFeedback", back_populates="user")


class Hospital(Base):
    __tablename__ = "hospitals"

    hospital_id = Column(Integer, primary_key=True, autoincrement=True)
    hospital_name = Column(String(100), nullable=False)
    location = Column(String(255))
    contact_info = Column(String(100))

    feedbacks = relationship("HospitalFeedback", back_populates="hospital")


class HealthLog(Base):
    __tablename__ = "healthlogs"

    log_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), ForeignKey("users.username", ondelete="CASCADE"))
    metric_type = Column(String(20))   # e.g., 'heart_rate', 'glucose', 'steps'
    value = Column(DECIMAL(10, 2))
    recorded_at = Column(TIMESTAMP, default=datetime.now)

    user = relationship("User", back_populates="health_logs")


class FoodLog(Base):
    __tablename__ = "foodlogs"

    log_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), ForeignKey("users.username", ondelete="CASCADE"))
    food_name = Column(String(100))
    calories = Column(Integer)
    logged_at = Column(TIMESTAMP, default=datetime.now)

    user = relationship("User", back_populates="food_logs")


class UserTarget(Base):
    __tablename__ = "usertargets"

    target_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), ForeignKey("users.username", ondelete="CASCADE"))
    metric_name = Column(String(20))   # e.g., 'daily_steps', 'target_weight'
    target_value = Column(DECIMAL(10, 2))
    current_progress = Column(DECIMAL(10, 2), default=0)
    is_completed = Column(Boolean, default=False)

    user = relationship("User", back_populates="targets")


class ConnectedDevice(Base):
    __tablename__ = "connecteddevices"

    device_id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(50), ForeignKey("users.username", ondelete="CASCADE"))
    device_name = Column(String(100))
    last_sync = Column(TIMESTAMP)

    user = relationship("User", back_populates="devices")
    settings = relationship("DeviceSetting", back_populates="device")


class DeviceSetting(Base):
    __tablename__ = "devicesettings"

    setting_id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(Integer, ForeignKey("connecteddevices.device_id", ondelete="CASCADE"))
    metric_to_sync = Column(String(20))
    is_active = Column(Boolean, default=True)

    device = relationship("ConnectedDevice", back_populates="settings")


class HospitalFeedback(Base):
    __tablename__ = "hospitalfeedback"

    feedback_id = Column(Integer, primary_key=True, autoincrement=True)
    hospital_id = Column(Integer, ForeignKey("hospitals.hospital_id"))
    username = Column(String(50), ForeignKey("users.username", ondelete="CASCADE"))
    feedback_text = Column(Text)
    medical_advice = Column(Text)
    created_at = Column(TIMESTAMP, default=datetime.now)

    hospital = relationship("Hospital", back_populates="feedbacks")
    user = relationship("User", back_populates="feedbacks")