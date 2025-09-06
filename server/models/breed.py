# filepath: server/models/breed.py
from . import db
from .base import BaseModel
from sqlalchemy.orm import validates, relationship

class Breed(BaseModel):
    __tablename__ = 'breeds'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    description = db.Column(db.Text)
    
    # Relationship with Dog model
    dogs = relationship('Dog', backref='breed_info', lazy=True)
    
    @validates('name')
    def validate_name(self, key, name):
        return self.validate_string_length('Breed name', name, min_length=2)
        
    @validates('description')
    def validate_description(self, key, description):
        return self.validate_string_length('Description', description, min_length=10, allow_none=True)
    
    def __repr__(self):
        return f'<Breed {self.name}>'