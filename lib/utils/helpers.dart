import 'package:flutter/material.dart';

class UiHelpers {
  static PreferredSizeWidget customAuthAppBar(
    BuildContext context,
    String? navigateTitle,
    VoidCallback? onTap, {
    bool showBackArrow = false,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70.0),
      child: AppBar(
        automaticallyImplyLeading: showBackArrow,
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/app_logo.jpg',
                        height: 36,
                        width: 36,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Testify Learn',
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: onTap,
                  child: Text(
                    navigateTitle != null ? navigateTitle : "",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget customTextField(
    BuildContext context, {

    required String hintText,
    required TextEditingController controller,
    required validator,
    String? labelText,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType:
          keyboardType ?? TextInputType.text, // Use provided or fallback
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: Theme.of(context).inputDecorationTheme.border,
      ),
    );
  }

  static Widget customButton(
    BuildContext context,
    String label,
    VoidCallback? onPressed,
  ) {
    return Center(
      child: SizedBox(
        width: 400,
        child: ElevatedButton(
          onPressed: onPressed,
          style: Theme.of(context).elevatedButtonTheme.style,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  static Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A5AE0),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  static AppBar customAppBarForScreen(
    context,
    String title, {
    bool automaticallyImplyLeading = false,
    List<Widget>? actions,
  }) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      iconTheme: const IconThemeData(color: Colors.white),

      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: false,
      actions: actions,
    );
  }

  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor ?? Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }


}
