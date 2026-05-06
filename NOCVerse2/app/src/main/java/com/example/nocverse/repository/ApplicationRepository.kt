package com.example.nocverse.repository

import com.example.nocverse.network.RetrofitInstance

class ApplicationRepository {

    suspend fun getApplications() =
        RetrofitInstance.api.getApplications()
}