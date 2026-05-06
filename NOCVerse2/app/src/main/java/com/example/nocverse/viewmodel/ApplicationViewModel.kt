package com.example.nocverse.viewmodel

import androidx.lifecycle.*
import com.example.nocverse.model.Application
import com.example.nocverse.repository.ApplicationRepository
import kotlinx.coroutines.launch

class ApplicationViewModel : ViewModel() {

    private val repository = ApplicationRepository()

    private val _applications = MutableLiveData<List<Application>>()
    val applications: LiveData<List<Application>> = _applications

    fun fetchApplications() {
        viewModelScope.launch {
            val response = repository.getApplications()
            if (response.isSuccessful) {
                _applications.postValue(response.body())
            }
        }
    }
}