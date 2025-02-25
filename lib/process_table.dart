import 'package:cpu_scheduler/table_controller.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import '/table_controller.dart';

class ProcessTable extends StatefulWidget {
  const ProcessTable({Key? key, required this.controller}) : super(key: key);
  final TableController controller;
  @override
  State<ProcessTable> createState() => _ProcessTableState();
}

class _ProcessTableState extends State<ProcessTable> {
  final List<PlutoColumn> columns = [];
  late TableController controller;

  late List<PlutoRow> rows;

  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    columns.addAll([
      PlutoColumn(
        frozen: PlutoColumnFrozen.left,
        title: 'Id',
        field: 'process_id',
        type: PlutoColumnType.text(),
        enableColumnDrag: false,
        readOnly: true,
        enableEditingMode: false,
        titleSpan: const TextSpan(children: [
          WidgetSpan(
              child: Icon(
            mat.Icons.lock_outlined,
            size: 17,
          )),
          TextSpan(text: 'Process ID'),
        ]),
      ),
      PlutoColumn(
        enableColumnDrag: false,
        title: 'Arrival Time',
        field: 'arrival_time',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        enableColumnDrag: false,
        title: 'Burst Time',
        field: 'burst_time',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        enableColumnDrag: false,
        title: 'Priority',
        field: 'priority',
        type: PlutoColumnType.number(),
      ),
    ]);

    rows = controller.processess;
  }

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: columns,
      rows: rows,
      onChanged: (PlutoGridOnChangedEvent event) {
        print(event);
        stateManager.notifyListeners();
      },
      onLoaded: (PlutoGridOnLoadedEvent event) {
        controller.setStateManager(event.stateManager);
        stateManager = event.stateManager;
      },
      // createHeader: (stateManager) => _Header(stateManager: stateManager),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
    required this.stateManager,
    Key? key,
  }) : super(key: key);

  final PlutoGridStateManager stateManager;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  int addCount = 1;

  int addedCount = 0;

  PlutoGridSelectingMode gridSelectingMode = PlutoGridSelectingMode.row;

  @override
  void initState() {
    super.initState();

    widget.stateManager.setSelectingMode(gridSelectingMode);
  }

  void handleAddRows() {
    final newRows = widget.stateManager.getNewRows(count: addCount);

    widget.stateManager.appendRows(newRows);

    widget.stateManager.setCurrentCell(
      newRows.first.cells.entries.first.value,
      widget.stateManager.refRows.length - 1,
    );

    widget.stateManager.moveScrollByRow(
      PlutoMoveDirection.down,
      widget.stateManager.refRows.length - 2,
    );

    widget.stateManager.setKeepFocus(true);
  }

  void handleRemoveCurrentColumnButton() {
    final currentColumn = widget.stateManager.currentColumn;

    if (currentColumn == null) {
      return;
    }

    widget.stateManager.removeColumns([currentColumn]);
  }

  void handleRemoveCurrentRowButton() {
    widget.stateManager.removeCurrentRow();
  }

  void handleRemoveSelectedRowsButton() {
    widget.stateManager.removeRows(widget.stateManager.currentSelectingRows);
  }

  void handleFiltering() {
    widget.stateManager
        .setShowColumnFilter(!widget.stateManager.showColumnFilter);
  }

  void setGridSelectingMode(PlutoGridSelectingMode? mode) {
    if (mode == null || gridSelectingMode == mode) {
      return;
    }

    setState(() {
      gridSelectingMode = mode;
      widget.stateManager.setSelectingMode(mode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            mat.DropdownButtonHideUnderline(
              child: mat.DropdownButton(
                value: addCount,
                items: [1, 5, 10, 50, 100]
                    .map<mat.DropdownMenuItem<int>>((int count) {
                  final color = addCount == count ? Colors.blue : null;

                  return mat.DropdownMenuItem<int>(
                    value: count,
                    child: Text(
                      count.toString(),
                      style: TextStyle(color: color),
                    ),
                  );
                }).toList(),
                onChanged: (int? count) {
                  setState(() {
                    addCount = count ?? 1;
                  });
                },
              ),
            ),
            mat.ElevatedButton(
              child: const Text('Add rows'),
              onPressed: handleAddRows,
            ),
            mat.ElevatedButton(
              child: const Text('Remove Current Column'),
              onPressed: handleRemoveCurrentColumnButton,
            ),
            mat.ElevatedButton(
              child: const Text('Remove Current Row'),
              onPressed: handleRemoveCurrentRowButton,
            ),
            mat.ElevatedButton(
              child: const Text('Remove Selected Rows'),
              onPressed: handleRemoveSelectedRowsButton,
            ),
            mat.ElevatedButton(
              child: const Text('Toggle filtering'),
              onPressed: handleFiltering,
            ),
            mat.DropdownButtonHideUnderline(
              child: mat.DropdownButton(
                value: gridSelectingMode,
                items: PlutoGridStateManager.selectingModes
                    .map<mat.DropdownMenuItem<PlutoGridSelectingMode>>(
                        (PlutoGridSelectingMode item) {
                  final color = gridSelectingMode == item ? Colors.blue : null;

                  return mat.DropdownMenuItem<PlutoGridSelectingMode>(
                    value: item,
                    child: Text(
                      item.toShortString(),
                      style: TextStyle(color: color),
                    ),
                  );
                }).toList(),
                onChanged: (PlutoGridSelectingMode? mode) {
                  setGridSelectingMode(mode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
