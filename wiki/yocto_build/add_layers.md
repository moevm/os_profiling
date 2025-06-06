# Как добавляются слои
1. Для добавления слоя нам необходим репозиторий этого слоя, поэтому первый шаг для добавления это клонирование репозитория.
2. Вторым шагом для добавления слоя является модификация файла /poky/build/conf/bblayers.conf, в нем необходимо добавить директорию слоя (куда только что склонировался репозиторий) в переменную BBLAYERS, это можно сделать вручную, но удобнее использовать утилиту bitbake'a: `bitbake-layers add-layer <путь_до_директории>`.

После выполнения этих двух шагов слой будет добавлен, если он совместим с базовым слоем.


## Попытка добавления слоев

1) meta-cgl (meta-cgl-common): зависит от filesystems-layer, networking-layer, openembedded-layer, perl-layer,
    security, selinux: 
    - filesystems-layer несовместим с базовым словем, совместим с styhead scarthgap
    - networking-layer несовместим с базовым словем, совместим с scarthgap styhead
    - oe-layer несовместим с базовым словем, совместим с scarthgap styhead
    - perl-layer несовместим с базовым словем, совместим с scarthgap styhead
2) meta-clang: всё добавилось
3) meta-cloud-services: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap, зависит от meta-virtualization
4) meta-dpdk: всё добавилось
5) meta-erlang: всё добавилось
6) meta-java: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
7) meta-openembedded: репозиторий содержит в себе много слоев,  несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap styhead
8) meta-qt5: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
9) meta-rust: слой несовместим с базовым слоем, даёт подсказку, что совместим с kirkstone honister mickledore hardknott gatesgarth
10) meta-security: слой зависит от openembedded-layer
11) meta-selinux: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap
12) meta-sysrepo: слой несовместим с базовым слоем, даёт подсказку, что совместим с honister
13) meta-virtualization: зависит от filesystems-layer, meta-python, networking-layer, openembedded-layer
14) meta-xilinx: репозиторий содержит в себе много слоев, неясно какой из них нужен, но они все так же несовместимы с базовым слоем, даёт подсказку, что совместимы с scarthgap
15) meta-xilinx-tools: слой несовместим с базовым слоем, даёт подсказку, что совместим с scarthgap, зависит от meta-xilinx и meta-xilinx-standalone


## Попытка добавления слоев после смены базового слоя на scarthgap

Был изменен порядок добавления слоев, так как некоторые слои зависят от других:
Порядок добавления:
1) meta-oe: добавлен (первым т.к. от него зависят другие слои)
2) meta-python: добавлен т.к. от него зависят другие слои
3) meta-networking: добавлен т.к. от него зависят другие слои
4) meta-filesystems: добавлен т.к. от него зависят другие слои
5) meta-perl: добавлен т.к. от него зависят другие слои
6) meta-security: добавлен (в начале т.к. от него зависят другие слои)
7) meta-selinux: добавлен (в начале т.к. от него зависят другие слои)
8) meta-cgl (meta-cgl-common): добавлен (на данном этапе уже есть все слои, от которых он зависит)
9) meta-clang: добавлен
10) meta-virtualization: добавлен (в начале т.к. от него зависят другие слои)
11) meta-cloud-services: добавлен (на данном этапе уже есть слой meta-virtualization, от которого он зависит)
12) meta-dpdk: добавлен
13) meta-erlang: добавлен
14) meta-java: добавлен
15) meta-qt5: добавлен
16) meta-xilinx: были добавлены meta-xilinx-core и meta-xilinx-standalone, т.к. от них зависит слой meta-xilinx-tools
17) meta-xilinx-tools: добавлен
18) meta-sysrepo: добавлен после конфигурации файла layer.conf (об этом ниже)
19) meta-rust: добавлен после конфигурации файла layer.conf (об этом ниже)

## Попытка изменения конфигурации слоев meta-rust и meta-sysrepo 

После анализа исходного кода bitbake'a была выявлена причина, по которой некоторые слои при добавлении оказываются несовместимы с базовым слоем: а именно, у каждого слоя в файле layer.conf изначально заданы базовые слои, с которым совместим данный слой. Совместимые слои перечислены через пробел в переменной LAYERSERIES_COMPAT_<название слоя>. Следовательно, если текущий базовый слой не указан в файле конфигурации как подходящий - выбрасывается ошибка. После выявления этой причины была произведена попытка изменения файлов layer.conf для слоев meta-rust и meta-sysrepo: в переменную LAYERSERIES_COMPAT был дописан слой scarthgap. После данного изменения оба слоя были добавлены без ошибок, однако данный подход вероятно может привести к дальнейшим ошибкам при сборке - этот вопрос следует исследовать.

### Остались не добавлены:
1) meta-ypl: так как был не найден


