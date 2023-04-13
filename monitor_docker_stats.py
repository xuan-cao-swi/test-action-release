# docker stats --format "table {{.Name}}\t{{.MemUsage}}"
# only show memory usage


import subprocess
import matplotlib.pyplot as plt
import datetime
import time
import re
import csv

def plot_graph(data,time_interval):

    # plt.plot(time_interval, data)

    rails_app_apm_mem_otel_data,rails_app_mem_data,rails_app_without_apm_mem_data = data

    fig, ax = plt.subplots(figsize=(len(rails_app_apm_mem_otel_data), max(rails_app_apm_mem_otel_data)))

    # plot lines
    ax.plot(time_interval, rails_app_apm_mem_otel_data, label = "rails_app_apm_mem_otel_data", linestyle="-")
    ax.plot(time_interval, rails_app_mem_data, label = "rails_app_mem_data", linestyle="-.")
    ax.plot(time_interval, rails_app_without_apm_mem_data, label = "rails_app_without_apm_mem_data", linestyle=":")
    ax.set_ylabel('Memory Usage')
    ax.set_xlabel('Time Interval')
    ax.legend()
    fig.savefig('MemoryUsageResult.png')

def plot_graph_from_csv(csvfile):

    rails_app_apm_mem_otel_data = []
    rails_app_mem_data = []
    rails_app_without_apm_mem_data = []

    csvreader = csv.reader(open(csvfile))

    for row in csvreader:
        rails_app_apm_mem_otel_data.append(float(row[0]))
        rails_app_mem_data.append(float(row[1]))
        rails_app_without_apm_mem_data.append(float(row[2]))

    print(max(rails_app_apm_mem_otel_data))
    print(max(rails_app_mem_data))
    print(max(rails_app_without_apm_mem_data))

    print("last")
    print(rails_app_apm_mem_otel_data[len(rails_app_apm_mem_otel_data)-1])
    print(rails_app_mem_data[len(rails_app_mem_data)-1])
    print(rails_app_without_apm_mem_data[len(rails_app_without_apm_mem_data)-1])
        
    time_interval = []
    for i in range(0,len(rails_app_without_apm_mem_data)):
        time_interval.append(i)

    fig, ax = plt.subplots()
    fig.set_size_inches(30, 20)

    # fig, ax = plt.subplots(figsize=(2**16, max(rails_app_apm_mem_otel_data)))

    ax.plot(time_interval, rails_app_apm_mem_otel_data, label = "rails_app_apm_mem_otel_data", linestyle="-")
    ax.plot(time_interval, rails_app_mem_data, label = "rails_app_mem_data", linestyle="-.")
    ax.plot(time_interval, rails_app_without_apm_mem_data, label = "rails_app_without_apm_mem_data", linestyle=":")
    ax.set_ylabel('Memory Usage')
    ax.set_xlabel('Time Interval')
    ax.legend()
    fig.savefig('MemoryUsageResult.png')



def monitor_docker_stats():

    rails_app_apm_mem_otel_data    = []
    rails_app_mem_data             = []
    rails_app_without_apm_mem_data = []

    time_interval = []

    iteration = 0
    while True:
        
        result = subprocess.check_output(['docker', 'stats', '--no-stream', '--format', '"{{.Name}}\t{{.MemUsage}}"'])
        results = result.decode('utf-8').split('\n')
        now = datetime.datetime.now().strftime("%M:%S")

        exist_data = 0
        for res in results:

            if res == '':
                continue

            container_name, mem = res.split('\t')
            mem_int = re.search("[0-9]+.[0-9]+MiB", mem)
            
            if mem_int == None:
                continue

            container_name = container_name.replace('"', '')

            usage = float(mem_int.group().replace('MiB',''))

            if container_name == 'rails_app_apm_mem_otel-1':
                rails_app_apm_mem_otel_data.append(usage)
                exist_data += 1
            elif container_name == 'rails_app_mem-1':
                rails_app_mem_data.append(usage)
                exist_data += 1
            elif container_name == 'rails_app_without_apm_mem-1':
                rails_app_without_apm_mem_data.append(usage)
                exist_data += 1

        if exist_data < 3:
            break
        else:
            time_interval.append(str(now))
            time.sleep(5)

        iteration += 1
        print("Running iteration {0}".format(iteration))

    data = [rails_app_apm_mem_otel_data,rails_app_mem_data,rails_app_without_apm_mem_data]

    max_range = min(len(rails_app_without_apm_mem_data),len(rails_app_mem_data),len(rails_app_without_apm_mem_data))

    data_for_writeout = []
    for i in range(0,max_range):
        data_for_writeout.append([rails_app_apm_mem_otel_data[i], rails_app_mem_data[i], rails_app_without_apm_mem_data[i]])

    output_file = open('mem_out_data.csv','w')
    csvwriter = csv.writer(output_file)
    csvwriter.writerows(data_for_writeout)
    output_file.close()

    plot_graph(data,time_interval)

def main():

    # monitor_docker_stats()
    plot_graph_from_csv('mem_out_data.csv')
    



# data = []
# time_interval = []
# for i in range(0,10):
#     data.append(i)
#     now = datetime.datetime.now().strftime("%M:%S")
#     time_interval.append(str(now))
#     time.sleep(i)

# plt.plot(time_interval, data)


if __name__ == '__main__':
    main()