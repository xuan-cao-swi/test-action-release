# docker stats --format "table {{.Name}}\t{{.MemUsage}}"
# only show memory usage


import subprocess
import matplotlib.pyplot as plt
import datetime
import time

def plot_graph(data,time_interval):

    # plt.plot(time_interval, data)

    rails_app_apm_mem_otel_data,rails_app_mem_data,rails_app_without_apm_mem_data = data
      
    # plot lines
    plt.plot(time_interval, rails_app_apm_mem_otel_data, label = "rails_app_apm_mem_otel_data", linestyle="-")
    plt.plot(time_interval, rails_app_mem_data, label = "rails_app_mem_data", linestyle="-.")
    plt.plot(time_interval, rails_app_without_apm_mem_data, label = "rails_app_without_apm_mem_data", linestyle=".")
    plt.ylabel('Memory Usage')
    plt.xlabel('Time Interval')
    plt.legend()
    plt.savefig('MemoryUsageResult.png')

def main():

    rails_app_apm_mem_otel_data    = []
    rails_app_mem_data             = []
    rails_app_without_apm_mem_data = []

    time_interval = []
    while True:
        
        result = subprocess.check_output(['docker', 'stats', '--no-stream', '--format', '"{{.Name}}\t{{.MemUsage}}"'])
        results = result.decode('utf-8').split('\n')
        now = datetime.datetime.now().strftime("%M:%S")
        
        exist_data = 0
        for res in results:
            container_name, mem = res.split('\t')
            mem_int = re.search("[0-9]+.[0-9]+MiB", mem)
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

            time_interval.append(str(now))

        if exist_data < 3:
            break
        else:
            time.sleep(5)

    data = [rails_app_apm_mem_otel_data,rails_app_mem_data,rails_app_without_apm_mem_data]

    plot_graph(data,time_interval)



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