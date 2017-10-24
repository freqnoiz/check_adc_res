# check_adc_res
Nagios plugin for checking Fortinet ADC Load balancer Resources 

##Plugin uses curl and ADC's REST API to gather and return stats in %. It needs to save cookie, so it does and it is stored in /tmp, once used, cookie gets deleted.

##Usage:
  
  -h <hostname/ip>
  -u <user>
  -p <password>
  -r <resource>
  -w <warning>
  -c <critical>

###To check CPU:
```bash
  check_adc_resource.sh -h fortinet.lb.example.org -u admin -p 5ecr3t -r cpu -w 70 -c 90
```

###To check RAM:
```bash
  check_adc_resource.sh -h fortinet.lb.example.org -u admin -p 5ecr3t0 -r cpu -w 80 -c 90
```

###To check DISK:
```bash
  check_adc_resource.sh -h fortinet.lb.example.org -u admin -p 5ecr3t -r disk -w 70 -c 95
```
