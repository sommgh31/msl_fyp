"""
Quick test script to verify backend is accessible from network
Run this to check if your backend is reachable
"""
import requests
import sys

def test_backend(ip='10.66.122.189', port=8000):
    """Test if backend is accessible"""
    url = f'http://{ip}:{port}/health'
    print(f'Testing backend at: {url}')
    
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            data = response.json()
            print('✅ Backend is accessible!')
            print(f'   Status: {data.get("status")}')
            print(f'   Model loaded: {data.get("model_loaded")}')
            return True
        else:
            print(f'❌ Backend returned status: {response.status_code}')
            return False
    except requests.exceptions.ConnectionError:
        print(f'❌ Cannot connect to {url}')
        print('   Check:')
        print('   1. Backend is running (python main.py)')
        print('   2. IP address is correct')
        print('   3. Firewall allows port 8000')
        return False
    except requests.exceptions.Timeout:
        print(f'❌ Connection timeout to {url}')
        return False
    except Exception as e:
        print(f'❌ Error: {e}')
        return False

if __name__ == '__main__':
    # Test with default IP
    ip = sys.argv[1] if len(sys.argv) > 1 else '10.66.122.189'
    test_backend(ip)

