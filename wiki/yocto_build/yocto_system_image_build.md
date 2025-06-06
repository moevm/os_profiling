# Yocto system image build
В этом файле рассмотрены следующие аспекты сборки Yocto:

+ Как в итоговый образ добавляются файлы/библиотеки/тд
+ Где это происходит в коде
+ В какой момент времени это происходит
+ Используется ли кэширование
+ Отличия слоев и классов

### Как в итоговый образ добавляются файлы/библиотеки/тд
В итоговый образ файлы и библиотеки добавляются с помощью bitbake, который выполняет рецепты, которые формирует Yocto. То есть (как я понял) - Yocto формирует рецепты (в зависимости от того, что мы хотим получить - например, если не хотим оконный интерфейс - не формируются рецепты для оконных интерфейсов и тд...), а выполняет все эти рецепты непосредственно bitbake, которые пробегается по рецептам и выполняет их - формирует образ, устанавливая библиотеки, зависимости, компилирует исходный код и тд.

### Где это происходит в коде
Все рецепты находят в дереве Yocto в папке ./meta, в которой они разбиты по папочками, которые начинаются на `recipes-<что-то>` . Разбиты они по принципу - в каждой папке лежат все реценты для определенного класса задача (например рецепты ядра, рецепты графических оболчек, рецепты взаимодействия со сторонними устройствами...).
Описание рецептов из /meta/recipes.txt:
```
recipes-bsp          - Anything with links to specific hardware or hardware configuration information
recipes-connectivity - Libraries and applications related to communication with other devices 
recipes-core         - What's needed to build a basic working Linux image including commonly used dependencies
recipes-devtools     - Tools primarily used by the build system (but can also be used on targets)
recipes-extended     - Applications which whilst not essential add features compared to the alternatives in
                       core. May be needed for full tool functionality.
recipes-gnome        - All things related to the GTK+ application framework
recipes-graphics     - X and other graphically related system libraries  
recipes-kernel       - The kernel and generic applications/libraries with strong kernel dependencies
recipes-multimedia   - Codecs and support utilties for audio, images and video
recipes-rt           - Provides package and image recipes for using and testing the PREEMPT_RT kernel
recipes-sato         - The Sato demo/reference UI/UX, its associated apps and configuration 
recipes-support      - Recipes used by other recipes but that are not directly included in images
```
Перевод описания рецептов из /meta/recipes.txt:
```
recipes-bsp          - Все, что связано со ссылками на конкретное оборудование (hardware) или информацию о конфигурации оборудования.
recipes-connectivity - Библиотеки и приложения, связанные со взаимо действиями с другими устройствами (devices)
recipes-core         - То, что необходимо для создания базового рабочего образа Linux, включая часто используемые зависимости
recipes-devtools     - Инструменты, в основном используемые системой сборки (но также могут "использоваться и на целевых объектах" - "used on targets") .
recipes-extended     - Приложения, которые, хотя и не являются существенными, добавляют функции по сравнению с альтернативами в ядре. Может потребоваться для полной функциональности инструмента. - не знаю смог ли вообще передать смысл, потому сверху есть оригинал 🙂
recipes-gnome        - Все, что связано с GTK и платформой приложений. (gtk = GIMP ToolKit - штука для gui в линуксе)
recipes-graphics     - X и другие графически связанные системные библиотеки. (Х = X Window System - штук для рисования окошек приложений в linux)
recipes-kernel       - Ядро и универсальные приложения/библиотеки с сильными зависимостями от ядра.
recipes-multimedia   - Кодеки и утилиты поддержки аудио, изображений и видео
recipes-rt           - Предоставляет рецепты пакетов и образов для использования и тестирования ядра PREEMPT_RT.
recipes-sato         - Демонстрационный/справочный пользовательский интерфейс/UX Sato, связанные с ним приложения и конфигурация. 
recipes-support      - Рецепты, используемые в других рецептах, но не включенные непосредственно в изображения.
```

Все эти инструкции, рецепты, классы, слои и тд устанавливает bitbake.
Грубо (очень грубо) говоря bitbake - это такой оркестратор установки - он управляет тем, как выполнять рецепты и прочее. (по этому инструменту очень много информации в папке bitbake/doc - в перспективе нужно подробно будет это дело изучить, потому что это прямо основа сборки образов в Yocto, но материала там очень много...)

### В какой момент времени это происходит

В BitBake, в файле /bitbake/lib/bb/utils.py реализованы обертки для часто используемых функций (таких, как создание дирекотрий и прочего, так например mkdirhier оборачивает 'mkdir -p', но так, что при попытке создать существующую директорию не вызываются ошибки).

Неправильным будет указать на определенный шаг, поскольку весь процесс сборки bitbake так или иначе завязан на подключении каких-то библиотек и модулей. Лучше тезисно обозначить основные этапы сборки образа через bitbake:

1. Создание рабочего дерева (Working directory): BitBake начинает с чтения и анализа метаданных из различных слоев (layers), включая рецепты (recipes), классы (classes), конфигурационные файлы и прочее. В результате формируется рабочее дерево, которое содержит всю необходимую информацию для сборки образа (что-то типо скелета).   
В файле **lib/bb/cooker.py** происходит обработка рецептов и создание рабочего дерева. Здесь происходит управление каталогами, в которых хранятся исходные коды пакетов, промежуточные результаты сборки и т.д.


2. Парсинг метаданных: BitBake анализирует метаданные, определяет зависимости между компонентами, конфигурации и тд. Это происходит в файле **lib/bb/codeparser.py** и в папке **lib/bb/parse.py** 

3. Конфигурация окружения: BitBake настраивает среду сборки, устанавливает переменные и параметры, необходимые для сборки образа.

4. Загрузка исходного кода: BitBake загружает исходные коды компонентов из источников (архивы, git репо) и распаковывает их в дереве. Это происходит в папке **lib/bb/fetch2.py** 

5. Компиляция и сборка компонентов: BitBake выполняет задачи сборки для каждого компонента, включая компиляцию, линковку, обработку зависимостей и упаковку исполняемых файлов, библиотек и других компонентов.

6. Генерация образа: После успешной компиляции всех компонентов, BitBake объединяет их в образ системы, включая файловую систему, ядро, загрузчики, конфигурационные файлы и другие необходимые компоненты.

7. Обработка и окончательные шаги: BitBake выполняет окончательные операции по подготовке образа для использования, такие как упаковка, подпись, документирование и т.д.

**lib/bb/runqueue.py**- этот файл отвечает за планирование и выполнение задач сборки. Здесь также происходит работа с рабочим деревом, включая копирование файлов, установку пакетов и т.д.

**lib/bb/build.py**- этот файл содержит функции для управления процессом сборки пакетов и компиляции проекта. Он предоставляет функциональность для запуска задач сборки, управления зависимостями и контроля над процессом сборки.

* промежуточный результат кэшируеся. Например, я начал собирать образ, он собрался на 90% после чего я экстренно завершил сборку, ровно через 20 дней решил дособирать - образ дособрался (а не пересобирался), то есть шаги кэшируются.  Работа с кэшем организована в файле **lib/bb/cache.py**

### Используется ли кэширование
Да, кэширование используется, кэш располагается в папках /build/cache, /build/sstate-cache и /build/tmp, а в папке ./build/downloads располагаются скачанные файлы (архивы, код, и тд). Также, как видно из предыдущего пункта - скомпилированные компоненты по мере компиляции записываются в специально созданную под них директорию в рабочем дереве сборки. 


### Концепция сборки (рецепты (задания), конфигураторы, классы, слои (уровни))
#### Рецепты (задания)
Задания BitBake, хранящиеся в файлах .bb, служат базовыми метаданными, обеспечивая BitBake:
- описания пакетов (автор, домашняя страница, лицензия и т. п.);
- версии заданий;
- имеющиеся зависимости (при сборке и работе);
- местоположение исходного кода и способ его извлечения;
- потребность в применении правок, их местоположение и способ применения;
- детали настройки и компиляции исходного кода;
- место установки программ на целевой машине.
В контексте BitBake или использующей программу системы сборки файлы .bb считаются заданиями. Иногда задания
называют пакетами, однако это не совсем корректно, поскольку одно задание может включать множество пакетов.

#### Конфигураторы (файлы конфигурации)
Конфигурационные файлы .conf задают переменные, управляющие процессом сборки. Эти файлы делятся на
несколько категорий, задающих конфигурацию машины и дистрибутива, опции компиляции, базовые и
пользовательские параметры. Основным файлом конфигурации служит bitbake.conf в каталоге conf дерева источников.

#### Классы
Файлы классов .bbclass содержат информацию, которая может совместно использоваться множеством файлов
метаданных. Классы из base.bbclass включаются автоматически для всех заданий и классов и содержат
определения стандартных базовых задач, таких как выборка, распаковка, настройка (по умолчанию пуст), компиляция
(запускается при наличии Makefile), инсталляция (по умолчанию пуст) и подготовка пакетов (по умолчанию пуст). Эти
задачи часто переопределяются или расширяются другими классами, созданными при разработке проектов. 

#### Слои (уровни)
Уровни позволяют разделить разные типы настроек. Может показаться заманчивым держать все в одном месте при
работе над проектом, однако модульная организация существенно упростит внесение изменений в проект.
Для иллюстрации применения уровней рассмотрим конфигурацию для конкретной целевой машины. Этот тип
настройки обычно выделяют в специальный уровень, называемый уровнем BSP1. Настройки для машины следует
изолировать от заданий и метаданных, поддерживающих, например, новую среду GUI. Однако важно понимать, что
уровень BSP может включать машинозависимые дополнения для заданий GUI без вмешательства в этот уровень. Это
делается с помощью файлов дополнения BitBake append (.bbappend). 

#### Файлы дополнения

Файлы дополнения .bbappend расширяют и переопределяют информацию имеющегося файла задания. BitBake
считает, что каждому файлу дополнения соответствует своё задание, имена дополнения и задания должны иметь
общий корень и могут различаться лишь суффиксом (например, formfactor_0.0.bb и formfactor_0.0.bbappend).
Информация в файле дополнения расширяет или переопределяет содержимое соответствующего файла задания. В
именах файлов дополнения можно применять шаблон %, позволяющий дополнять множество заданий сразу.
Например, файл busybox_1.21.%.bbappend будет соответствовать заданиям busybox_1.21.x.bb разных версий.


Источник [En]: https://docs.yoctoproject.org/bitbake/    
Источник [Ru]: https://www.protokols.ru/WP/wp-content/uploads/2019/12/BitBake-User-Manual.pdf
