## Условия проведения эксперимента
Эксперимент проводился на слудующем коммите poky: commit_hash=`e18d60deb0496f7c91f2de900d6c024b45b7910a`


## Структура таблицы sources

В таблице представлены следующие столбцы:
1. Sec - количество секунд с начала сборки
2. CPU - нагрузка на CPU, %
3. IO - нагрузка на IO, %
4. RAM - нагрузка на RAM, %
5. Running tasks - задачи, работающие в данный момент
6. Buildable tasks - задачи, готовые к запуску
7. Buildable tasks types - типы задач, готовых к запуску, и их количество соответственно
8. Skip start running info - информация, говорящая о том, почему запуск задачи был отменен


Столбцы 2, 3 и 4 раскрашены цветом по градиенту от зеленого к красному в зависимости от процента нагрузки (0% - зеленый, 100% - красный).


### Замечания

1. Поскольку информация об очереди задач обновляется тогда, когда запускается задача, а информация о нагрузке обновляется раз в секунду, то может произойти следующая ситуация: в секунду n в очереди есть несколько задач, а в секунду n+1 не написано ни одной задачи. Это значит, что очередь выполнения не изменилась и осталась такой же, как в секунду n.
2. Поскольку очередь может обновляться значительно чаще, чем раз в секунду, допускается погрешность данных об очереди, равная 1 секунде.
3. Если в какую-то секунду столбцы `Buildable tasks` и `Buildable tasks types` непусты, а в столбце `Skip start running info` написано "no buildable tasks" - это значит, что за эту секунду в очереди побыавли задачи, указанные в столбце `Buildable tasks`, а также за эту же секунду произошла ситуация, когда в очереди не было задач, и из-за Bitbake не смог запустить задачу. 

## Выводы

В результате были получены следующие результаты:
1) в течение примерно первой половины времени сборки bitbake использует все допустимые потоки, и из-за этого не может запустить больше задач
2) когда потоки освобождаются, практически сразу мы сталкиваемся с ситуацией, что в очереди нет buildable(готовых к запуску) задач
