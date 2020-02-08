import boto3
import csv

s3 = boto3.resource('s3')

bucket_name='mammography-workshop-files-us-east-2-582783967438'
my_images_bucket = s3.Bucket(bucket_name)

# prefix = 'raw-jpg'
prefix = 'resize'

s3train = '{}/train/'.format(prefix)
s3validation = '{}/test/'.format(prefix)

s3train_lst = '{}/train-data.lst'.format(prefix)
s3validation_lst = '{}/test-data.lst'.format(prefix)


dictionary = {'NAO': '0', 'CCD': '1', 'CCE': '2', 'MLOD': '3', 'MLOE': '4'}

with open('/tmp/train-data.lst', 'w', newline='') as file:
    writer = csv.writer(file, delimiter = '\t')
    cont = 0
    for object_summary in my_images_bucket.objects.filter(Prefix=s3train):
        s = object_summary.key
        if s.endswith("jpg") or s.endswith("jpeg") or s.endswith("bmp") or s.endswith("png"):
            cont += 1
            ss = s[len(s3train)::]
            k = str(ss.split('/')[0])
            l = "{}\t{}\t{}".format(cont, dictionary.get(k), ss)
            print(l)
            writer.writerow([cont, dictionary.get(k), ss])

with open('/tmp/test-data.lst', 'w', newline='') as file:
    writer = csv.writer(file, delimiter = '\t')
    cont = 0
    for object_summary in my_images_bucket.objects.filter(Prefix=s3validation):
        s = object_summary.key
        if s.endswith("jpg") or s.endswith("jpeg") or s.endswith("bmp") or s.endswith("png"):
            cont += 1
            ss = s[len(s3validation)::]
            k = str(ss.split('/')[0])
            l = "{}\t{}\t{}".format(cont, dictionary.get(k), ss)
            print(l)
            writer.writerow([cont, dictionary.get(k), ss])
            
s3.meta.client.upload_file('/tmp/train-data.lst', bucket_name, s3train_lst)
s3.meta.client.upload_file('/tmp/test-data.lst', bucket_name, s3validation_lst)