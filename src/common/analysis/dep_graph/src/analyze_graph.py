import networkx as nx
from pathlib import Path
from .match_graph_names import sort_start_time, match


DEP_GRAPH_DIR = Path(__file__).parent.parent.absolute()


def analyze_graph(dotfilename, info, create_txt=False):
    G = nx.DiGraph(nx.nx_pydot.read_dot(dotfilename))
    sorted_tasks = sort_start_time(info)
    sorted_nodes = []
    for node in G.nodes:  # for each node, find the corresponding index in sorted_tasks
        index, start, end = match(node, sorted_tasks)
        sorted_nodes.append((index, node, start, end))

    sorted_nodes = sorted(sorted_nodes, key=lambda x:x[0])

    results = []
    for node in G.nodes:
        for child in G.neighbors(node):
            for temp in sorted_nodes:
                if temp[1] == node:
                    result1 = temp
                if temp[1] == child:
                    result2 = temp
            if result1[2] != -1 and result2[3] != -1:
                offset = result1[2] - result2[3]
            else:
                offset = -1
            results.append((f'node: {node}, Started: {result1[2]}, child: {child}, Ended: {result2[3]}',  offset))

    results = sorted(results, key=lambda x: x[1], reverse=True)


    if create_txt:
        with open(DEP_GRAPH_DIR / "text-files" / "task-order-sorted-offset.txt", 'w') as file:
            file.writelines(f"{item[0]}, offset: {item[1]}\n" for item in results)

    return results


def graph_task_children(dotfilename):
    G = nx.DiGraph(nx.nx_pydot.read_dot(dotfilename))

    task_children = {}
    for node in G.nodes:
        for _ in G.neighbors(node):
            task_children[node] = task_children.get(node, 0) + 1

    with open(DEP_GRAPH_DIR / "text-files" / "task-children.txt", 'w') as file:
        file.writelines(f"{key} {value}\n" for key, value in task_children.items())
