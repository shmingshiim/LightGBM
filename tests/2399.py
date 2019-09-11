import matplotlib.pyplot as plt
import lightgbm
from catboost.datasets import titanic

from lightgbm import __version__ as lgb_ver
from matplotlib import __version__ as mpl_ver
from catboost import __version__ as cbs_ver

print("LightGBM: {}".format(lgb_ver))
print("matplotlib: {}".format(mpl_ver))
print("CatBoost: {}".format(cbs_ver))

train, test = titanic()

target = train['Survived']
train.drop('Survived', inplace=True, axis=1)

train.drop(['Name', 'Sex', 'Ticket', 'Cabin', 'Embarked'], inplace=True, axis=1)
test.drop(['Name', 'Sex', 'Ticket', 'Cabin', 'Embarked'], inplace=True, axis=1)

clf = lightgbm.LGBMClassifier()

print(1)
clf.fit(train, target)
print(clf.booster_.dump_model()['name'])
print(2)
clf.fit(train, target)
print(clf.booster_.dump_model()['name'])
print(3)
plt.savefig('1.png')
print(4)
clf.fit(train, target)
print(clf.booster_.dump_model()['name'])
print(5)
