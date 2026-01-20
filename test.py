import pickle

with open("/DATA/disk1/yjb/projects/VLA/RLinf/logs/demo_20260120-09:42:55/data.pkl", "rb") as f:
    data = pickle.load(f)

print(data[0])