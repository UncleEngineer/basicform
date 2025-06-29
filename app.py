from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)  # เปิดใช้ CORS สำหรับ Flutter

# กำหนดค่าฐานข้อมูล SQLite
basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'security_app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Model สำหรับเก็บข้อมูลการเข้าออก
class VisitorEntry(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    license_plate = db.Column(db.String(20), nullable=False)
    house_number = db.Column(db.String(50), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        return {
            'id': self.id,
            'license_plate': self.license_plate,
            'house_number': self.house_number,
            'timestamp': self.timestamp.isoformat()
        }

# สร้างตารางในฐานข้อมูล
with app.app_context():
    db.create_all()

# API Routes

@app.route('/api/entries', methods=['POST'])
def create_entry():
    """สร้างรายการใหม่"""
    try:
        data = request.get_json()
        
        if not data or 'license_plate' not in data or 'house_number' not in data:
            return jsonify({'error': 'ข้อมูลไม่ครบถ้วน กรุณาระบุป้ายทะเบียนและบ้านเลขที่'}), 400
        
        # ตรวจสอบข้อมูลว่าง
        license_plate = data['license_plate'].strip()
        house_number = data['house_number'].strip()
        
        if not license_plate or not house_number:
            return jsonify({'error': 'ป้ายทะเบียนและบ้านเลขที่ต้องไม่เป็นค่าว่าง'}), 400
        
        # สร้างรายการใหม่
        entry = VisitorEntry(
            license_plate=license_plate,
            house_number=house_number
        )
        
        db.session.add(entry)
        db.session.commit()
        
        return jsonify({
            'message': 'บันทึกข้อมูลสำเร็จ',
            'entry': entry.to_dict()
        }), 201
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'เกิดข้อผิดพลาด: {str(e)}'}), 500

@app.route('/api/entries', methods=['GET'])
def get_entries():
    """ดึงรายการทั้งหมด"""
    try:
        page = request.args.get('page', 1, type=int)
        per_page = request.args.get('per_page', 20, type=int)
        
        entries = VisitorEntry.query.order_by(VisitorEntry.timestamp.desc()).paginate(
            page=page, per_page=per_page, error_out=False
        )
        
        return jsonify({
            'entries': [entry.to_dict() for entry in entries.items],
            'total': entries.total,
            'pages': entries.pages,
            'current_page': page
        })
        
    except Exception as e:
        return jsonify({'error': f'เกิดข้อผิดพลาด: {str(e)}'}), 500

@app.route('/api/entries/<int:entry_id>', methods=['GET'])
def get_entry(entry_id):
    """ดึงรายการตาม ID"""
    try:
        entry = VisitorEntry.query.get_or_404(entry_id)
        return jsonify(entry.to_dict())
    except Exception as e:
        return jsonify({'error': f'ไม่พบรายการที่ระบุ'}), 404

@app.route('/api/entries/<int:entry_id>', methods=['PUT'])
def update_entry(entry_id):
    """อัพเดทรายการ"""
    try:
        entry = VisitorEntry.query.get_or_404(entry_id)
        data = request.get_json()
        
        if 'license_plate' in data:
            license_plate = data['license_plate'].strip()
            if license_plate:
                entry.license_plate = license_plate
        
        if 'house_number' in data:
            house_number = data['house_number'].strip()
            if house_number:
                entry.house_number = house_number
        
        db.session.commit()
        
        return jsonify({
            'message': 'อัพเดทข้อมูลสำเร็จ',
            'entry': entry.to_dict()
        })
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'เกิดข้อผิดพลาด: {str(e)}'}), 500

@app.route('/api/entries/<int:entry_id>', methods=['DELETE'])
def delete_entry(entry_id):
    """ลบรายการ"""
    try:
        entry = VisitorEntry.query.get_or_404(entry_id)
        db.session.delete(entry)
        db.session.commit()
        
        return jsonify({'message': 'ลบรายการสำเร็จ'})
        
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': f'เกิดข้อผิดพลาด: {str(e)}'}), 500

@app.route('/api/search', methods=['GET'])
def search_entries():
    """ค้นหารายการ"""
    try:
        license_plate = request.args.get('license_plate', '')
        house_number = request.args.get('house_number', '')
        
        query = VisitorEntry.query
        
        if license_plate:
            query = query.filter(VisitorEntry.license_plate.contains(license_plate))
        
        if house_number:
            query = query.filter(VisitorEntry.house_number.contains(house_number))
        
        entries = query.order_by(VisitorEntry.timestamp.desc()).all()
        
        return jsonify({
            'entries': [entry.to_dict() for entry in entries],
            'total': len(entries)
        })
        
    except Exception as e:
        return jsonify({'error': f'เกิดข้อผิดพลาด: {str(e)}'}), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """ตรวจสอบสถานะ API"""
    return jsonify({'status': 'API ทำงานปกติ', 'timestamp': datetime.utcnow().isoformat()})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)