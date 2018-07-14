
import glob

print('count lines in my source code...')
total_count = 0
with open('countfile', 'w') as out:
    list_of_files = glob.glob('ee_*.lua')
    for file_name in list_of_files:
        with open(file_name, 'r') as f:
            count = sum(1 for line in f)
            total_count += count
            print('{c:<8}{f}'.format(c=count, f=file_name))
print('counted {} total lines!'.format(total_count))
