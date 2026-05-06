package com.example.nocverse.network

import com.example.nocverse.model.Application
import retrofit2.Response
import retrofit2.http.GET

interface ApiService {

    @GET("applications")
    suspend fun getApplications(): Response<List<Application>>
}