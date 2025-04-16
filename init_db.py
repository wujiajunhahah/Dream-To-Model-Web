from app import app, db, User
from werkzeug.security import generate_password_hash

def init_db():
    with app.app_context():
        # 创建所有表
        db.create_all()
        
        # 检查是否已存在管理员用户
        admin = User.query.filter_by(username='123').first()
        if not admin:
            # 创建管理员用户
            admin = User(
                username='123',
                email='admin@example.com',
                is_active=True,
                is_admin=True
            )
            admin.set_password('123')
            db.session.add(admin)
            db.session.commit()
            print('管理员用户创建成功')
        else:
            print('管理员用户已存在')

if __name__ == '__main__':
    init_db() 