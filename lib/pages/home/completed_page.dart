import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:task_api_review/components/app_dialog.dart';
import 'package:task_api_review/components/td_search_box.dart';
import 'package:task_api_review/models/task_model.dart';
import 'package:task_api_review/pages/home/widgets/card_task.dart';
import 'package:task_api_review/resources/app_color.dart';
import 'package:task_api_review/services/remote/body/task_body.dart';
import 'package:task_api_review/services/remote/task_services.dart';
import 'package:task_api_review/utils/enum.dart';

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});

  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  final searchController = TextEditingController();
  final editController = TextEditingController();
  final editFocus = FocusNode();

  ///===========================///
  TaskServices taskServices = TaskServices();
  List<TaskModel> tasks = [];
  List<TaskModel> tasksSearch = [];

  @override
  void initState() {
    super.initState();
    _getCompletedTasks();
  }

  // Get List Task Completed
  Future<void> _getCompletedTasks() async {
    final query = {
      'status': StatusType.DONE.name,
      'deleted': false,
    };

    taskServices.getListTask(queryParams: query).then((response) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        List<Map<String, dynamic>> maps = (data['body']['docs'] ?? [])
            .cast<Map<String, dynamic>>() as List<Map<String, dynamic>>;
        tasks = maps.map((e) => TaskModel.fromJson(e)).toList();
        tasksSearch = [...tasks];
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('$onError 😐');
    });
  }

  void _updateTask(TaskBody body) {
    taskServices.updateTask(body).then((response) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        tasks.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;
        tasksSearch.singleWhere((element) => element.id == body.id)
          ..name = body.name
          ..description = body.description
          ..status = body.status;

        if (body.status == StatusType.PROCESSING.name) {
          tasks.removeWhere((element) => element.id == body.id);
          tasksSearch.removeWhere((element) => element.id == body.id);
        }

        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('$onError 😐');
    });
  }

  void _deleteTask(String id) {
    taskServices.deleteTask(id).then((response) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        tasks.removeWhere((element) => (element.id ?? '') == id);
        tasksSearch.removeWhere((element) => (element.id ?? '') == id);
        setState(() {});
      } else {
        print('object message ${data['message']}');
      }
    }).catchError((onError) {
      print('$onError 😐');
    });
  }

  void _search(String value) {
    value = value.toLowerCase();
    tasksSearch = tasks
        .where((element) => (element.name ?? '').toLowerCase().contains(value))
        .toList();
    setState(() {});
  }

  void _onEdit(TaskModel task) {
    setState(() {
      // close all edit task before open new edit task
      for (var element in tasks) {
        element.isEditing = false;
      }
      task.isEditing = true;
      editController.text = task.name ?? '';
      editFocus.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TdSearchBox(
            controller: searchController,
            onChanged: (value) => _search(value),
          ),
        ),
        const SizedBox(height: 16.0),
        const Divider(
          height: 2.0,
          indent: 20.0,
          endIndent: 20.0,
          color: AppColor.primary,
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(
                  child: Text(
                    'No completed task',
                    style: TextStyle(color: AppColor.brown, fontSize: 20.0),
                  ),
                )
              : SingleChildScrollView(
                  // physics: const AlwaysScrollableScrollPhysics(),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    itemCount: tasksSearch.length,
                    reverse: true,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final task = tasksSearch[index];
                      return CardTask(
                        task,
                        editController: editController,
                        editFocus: editFocus,
                        onTap: () => AppDialog.dialog(
                          context,
                          title: '😍',
                          content: 'The task status will be changed?',
                          action: () {
                            final body = TaskBody()
                              ..id = task.id
                              ..name = task.name
                              ..description = task.description
                              ..status = StatusType.PROCESSING.name;
                            _updateTask(body);
                          },
                        ),
                        onEdit: () => _onEdit(task),
                        onLongPress: () => _onEdit(task),
                        onSave: () {
                          final body = TaskBody()
                            ..id = task.id
                            ..name = editController.text.trim()
                            ..description = task.description
                            ..status = task.status;
                          _updateTask(body);
                          setState(() {
                            task.isEditing = false;
                          });
                        },
                        onCancel: () {
                          setState(() {
                            task.isEditing = false;
                          });
                        },
                        onDeleted: () => AppDialog.dialog(
                          context,
                          title: '😐',
                          content: 'Do you want to delete this task?',
                          action: () => _deleteTask(task.id ?? ''),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16.4),
                  ),
                ),
        ),
      ],
    );
  }
}
