package com.example.nocverse.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.*
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.nocverse.model.*
import kotlinx.coroutines.launch

@Composable
fun NewApplicationScreen(navController: NavController) {

    var title by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("NOC") }
    var priority by remember { mutableStateOf("Medium") }
    var description by remember { mutableStateOf("") }

    val scope = rememberCoroutineScope()

    val context = androidx.compose.ui.platform.LocalContext.current
    val db = AppDatabase.getDatabase(context)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF0B1220))
            .padding(16.dp)
    ) {

        Text("Create Application", color = Color.White)

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = title,
            onValueChange = { title = it },
            label = { Text("Title") },
            textStyle = LocalTextStyle.current.copy(color = Color.White),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = category,
            onValueChange = { category = it },
            label = { Text("Category") },
            textStyle = LocalTextStyle.current.copy(color = Color.White)
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = priority,
            onValueChange = { priority = it },
            label = { Text("Priority") },
            textStyle = LocalTextStyle.current.copy(color = Color.White)
        )

        Spacer(modifier = Modifier.height(12.dp))

        OutlinedTextField(
            value = description,
            onValueChange = { description = it },
            label = { Text("Description") },
            textStyle = LocalTextStyle.current.copy(color = Color.White),
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(20.dp))

        Button(
            onClick = {
                scope.launch {

                    val context = LocalContext.current

                    Button(
                        onClick = {
                            LocalStorage.saveApplication(
                                context,
                                title,
                                category,
                                priority,
                                description
                            )

                            NotificationManager.notifications.add("New Application: $title")

                            navController.popBackStack()
                        },
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Text("Submit Application")
                    }


                    navController.popBackStack()
                }
            },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Submit Application")
        }
    }
}