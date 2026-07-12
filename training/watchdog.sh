#!/bin/bash
PID=21522
while kill -0 $PID 2>/dev/null; do
  RSS_KB=$(ps -o rss= -p $PID 2>/dev/null | tr -d ' ')
  if [ -n "$RSS_KB" ] && [ "$RSS_KB" -gt 8000000 ]; then
    echo "警告：PID $PID RSS 已達 $((RSS_KB/1024))MB，超過 8GB 門檻，強制終止" 
    kill -9 $PID
    exit 1
  fi
  sleep 15
done
echo "process $PID 已正常結束"
