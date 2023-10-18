import 'dart:ui';

import 'package:bloc_change_text/core/constants.dart';
import 'package:bloc_change_text/core/enums.dart';
import 'package:bloc_change_text/core/global.dart';
import 'package:bloc_change_text/domain/models/tasks.dart';
import 'package:bloc_change_text/presentation/home/add_todo_screen.dart';
import 'package:bloc_change_text/root_screen.dart';
import 'package:bloc_change_text/widgets/showdialogue.dart';
import 'package:bloc_change_text/widgets/snackbars.dart';
import 'package:flutter/material.dart';

import '../../../application/bloc_exports.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    Key? key,
    required this.task,
  }) : super(key: key);
  final Task task;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchBloc, SwitchState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.only(right: 30, left: 30, bottom: 20),
          child: Container(
            decoration: boxDecoration(state),
            child: ExpansionTile(
              tilePadding: tilePadding(),
              leading: RootScreen.selectedIndexNotifier.value == 2
                  // check box
                  ? TodoBox(task: task, state: state)
                  : TodoBox(
                      task: task,
                      state: state,
                      onChanged: task.isDeleted == false
                          ? (bool? value) {
                              context
                                  .read<TaskBloc>()
                                  .add(UpdateTask(task: task));
                            }
                          : null,
                    ),
              // title text
              title: Text.rich(
                TextSpan(text: task.title),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Helvatica_lite',
                  decoration: task.isDone == true
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: task.isDone == true
                      ? state.switchValue
                          ? const Color(0xFF575862)
                          : Colors.grey
                      : state.switchValue
                          ? const Color(0xFFDDDDDD)
                          : Colors.black,
                ),
              ),
              // description
              subtitle: Text('${task.day} | ${task.time}',
                  // '${todo.day} | ${todo.time}',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Helvatica_lite',
                    color: task.isDone == true
                        ? state.switchValue
                            ? const Color(0xFF474853)
                            : Colors.grey
                        : state.switchValue
                            ? const Color(0xFF656A85)
                            : const Color.fromARGB(255, 92, 92, 92),
                  )),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: ListTile(
                    title: const Text('Title'),
                    subtitle: Text(task.title),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: ListTile(
                    title: const Text('Description'),
                    subtitle: Text(
                      task.description.isEmpty
                          ? 'No Description given'
                          : task.description,
                      style: TextStyle(
                        color: task.description.isEmpty
                            ? const Color.fromARGB(255, 209, 209, 209)
                            : null,
                      ),
                    ),
                  ),
                ),
                if (task.isDeleted == true)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TodoActionWidgets(
                        icon: Icons.restore_from_trash_rounded,
                        onPressed: () {
                          context.read<TaskBloc>().add(RestoreTask(task: task));
                        },
                        state: state,
                        text: 'Restore',
                      ),
                      //
                      TodoActionWidgets(
                        state: state,
                        icon: Icons.delete_forever_rounded,
                        onPressed: () {},
                        text: 'Delete Forever',
                      )
                    ],
                  ),
                if (task.isDeleted == false)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TodoActionWidgets(
                        state: state,
                        icon: Icons.edit,
                        onPressed: () {
                          titleController.text = task.title;
                          descriptionController.text = task.description;
                          showAddTodoPopup(
                            context,
                            type: PopupType.edit,
                            oldTask: task,
                          );
                        },
                        text: 'edit todo',
                      ),
                      //
                      TodoActionWidgets(
                        state: state,
                        icon: task.isFavourite == false
                            ? Icons.bookmark
                            : Icons.bookmark_added,
                        onPressed: () {
                          print(task.isFavourite);
                          context.read<TaskBloc>().add(
                                MarkFavOrUnFavTask(task: task),
                              );
                          task.isFavourite == false
                              ? snackBar('Added to favourite', context)
                              : snackBar('Removed from Favourite', context);
                        },
                        text: task.isFavourite == false
                            ? 'add to fav'
                            : 'remove from fav',
                      ),
                      //
                      TodoActionWidgets(
                        state: state,
                        icon: Icons.delete,
                        onPressed: () {
                          dialogueCard(
                            context: context,
                            description:
                                'Are you sure that you want to delete this task?',
                            head: 'Delete Task',
                            onPressed: () {
                              removeOrDeleteTask(context, task);
                              Navigator.pop(context);
                            },
                            state: state,
                          );
                        },
                        text: 'move to bin',
                      ),
                    ],
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  EdgeInsets tilePadding() {
    return const EdgeInsets.only(
      left: 5,
      right: 20,
      top: 5,
      bottom: 5,
    );
  }

  BoxDecoration boxDecoration(SwitchState state) {
    return BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 0.0),
            blurRadius: 18.0,
            spreadRadius: -15,
          ), //BoxShadow
        ],
        color: state.switchValue ? Constants.appDarkThemeColor : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              state.switchValue ? Constants.cancelButtonColorDark : Colors.grey,
        ));
  }
}

class TodoBox extends StatelessWidget {
  const TodoBox({
    Key? key,
    required this.task,
    required this.state,
    this.onChanged,
  }) : super(key: key);

  final Task task;
  final SwitchState state;
  final Function(bool?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Checkbox(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      splashRadius: 15,
      checkColor: state.switchValue ? Colors.black : Colors.white,
      fillColor: MaterialStateProperty.all<Color>(
        state.switchValue ? Colors.white : Constants.appThemeColor,
      ),
      value: task.isDone,
      onChanged: onChanged,
    );
  }
}

class TodoActionWidgets extends StatelessWidget {
  const TodoActionWidgets({
    Key? key,
    required this.state,
    required this.icon,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  final SwitchState state;
  final String text;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: text,
      onPressed: onPressed,
      icon: Icon(
        icon,
        color:
            state.switchValue ? Constants.cancelButtonColorDark : Colors.grey,
      ),
    );
  }
}

void removeOrDeleteTask(BuildContext ctx, Task task) {
  if (task.isDeleted == true) {
    ctx.read<TaskBloc>().add(DeleteTask(task: task));
    snackBar('Moved to bin', ctx);
  } else {
    ctx.read<TaskBloc>().add(RemoveTask(task: task));
    snackBar('Deleted Succesfully', ctx);
  }
}
