# Создание http кэш сервера 
### Локальная подготовка 
1) Необходимо произвести сборку образа
2) Скопировать папки poky/build/dowloads и poky/build/sstate-cache в какую-то стороннюю директорию
### Запуск сервера 
1) В новой директории с копированным файлами ввести команду `python3 -m http.server 8000` -- число = порт (если он у вас локально занят - меняйте на другой, разницы нет)   
![Screenshot from 2024-04-25 17-55-32](https://github.com/moevm/os_profiling/assets/90711883/ef1cfd20-acf7-4cfc-b9af-8926f4343546)
2) проверка того, что сервер работает - в браузере `http://localhost:8000/` -- число = порт (если он у вас локально занят - меняйте на другой, разницы нет)   
![Screenshot from 2024-04-25 17-56-55](https://github.com/moevm/os_profiling/assets/90711883/976a1b69-15ca-4d47-bf92-09edbdb339c9)
