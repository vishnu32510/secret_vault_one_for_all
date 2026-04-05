import 'package:get_it/get_it.dart';
import 'package:secretvaultoneforall/core/config/global_keys.dart';
import 'package:secretvaultoneforall/core/services/toast_service.dart';
import 'package:secretvaultoneforall/features/theme/theme_bloc.dart';

final getIt = GetIt.instance;

void setupDI() {
  if (!getIt.isRegistered<IToastService>()) {
    getIt.registerLazySingleton<IToastService>(
      () => ToastService(messengerKey: scaffoldMessengerKey),
    );
  }

  if (!getIt.isRegistered<ThemeBloc>()) {
    getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
  }
}
