package com.example.nocverse.ui

import androidx.compose.runtime.Composable
import androidx.navigation.compose.*
import com.example.nocverse.ui.screens.DashboardScreen
import com.example.nocverse.ui.screens.NewApplicationScreen
import com.example.nocverse.ui.screens.NotificationScreen

@Composable
fun AppNavigation() {

    val navController = rememberNavController()

    NavHost(
        navController = navController,
        startDestination = "dashboard"
    ) {

        // 🟢 Dashboard Screen
        composable("dashboard") {
            DashboardScreen(navController)
        }

        // 🔔 Notification Screen
        composable("notifications") {
            NotificationScreen()
        }

        // ➕ New Application Screen
        composable("new_application") {
            NewApplicationScreen(navController)
        }
    }
}