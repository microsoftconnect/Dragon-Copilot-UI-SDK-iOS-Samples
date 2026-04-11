/*
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 */

package com.microsoft.dragoncopilot.sampleapp

import androidx.core.net.toUri
import androidx.lifecycle.ViewModel
import com.microsoft.dragoncopilot.sampleapp.network.AuthTokenService
import com.microsoft.dragoncopilot.sampleapp.network.NetworkClientProvider
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logVerbose
import com.microsoft.dragoncopilot.turnkey.model.input.AuthType
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.time.ZoneOffset
import java.time.ZonedDateTime

class MainActivityViewModel(val configData: ConfigData, val authTokenService: AuthTokenService) : ViewModel() {
    private val viewModelScope = CoroutineScope(Dispatchers.IO)
    private val _uiState = MutableStateFlow<PartnerAppUiScreenState>(PartnerAppUiScreenState.Idle)
    val uiState: StateFlow<PartnerAppUiScreenState> = _uiState.asStateFlow()

    fun onEvent(event: PartnerAppUiScreenEvent) {
        when (event) {
            is PartnerAppUiScreenEvent.AcquireToken -> {
                when (event.configData.authType) {
                    AuthType.PARTNER_TOKEN -> {
                        logVerbose("Acquiring partner token for config: ${event.configData}")
                        viewModelScope.launch {
                            getPartnerToken(event.configData)?.let {
                                _uiState.emit(PartnerAppUiScreenState.TokenAcquired(it))
                            } ?: run {
                                _uiState.emit(PartnerAppUiScreenState.Idle)
                            }
                        }
                    }

                    AuthType.SMART_ON_FHIR -> {
                        logVerbose("Acquiring SoF token for config: ${event.configData}")
                        viewModelScope.launch {
                            var partnerToken: String? = null
                            val partnerTokenRequest = async { partnerToken = getPartnerToken(event.configData) }
                            partnerTokenRequest.await()
                            partnerToken?.let {
                                logVerbose("Acquired partner token, now acquiring SoF token")
                                val response = authTokenService.getSofToken(getSofTokenUrl(event.configData.userId), it)
                                if (response is NetworkClientProvider.Response.Success) {
                                    _uiState.emit(
                                        PartnerAppUiScreenState.TokenAcquired(
                                            issuer = response.data.issuer,
                                            launch = response.data.launch
                                        )
                                    )
                                } else {
                                    _uiState.emit(PartnerAppUiScreenState.Idle)
                                }
                            }
                        }
                    }

                    else -> {
                        logVerbose("Unsupported auth type: ${event.configData.authType}")
                    }
                }
            }
        }
    }

    private suspend fun getPartnerToken(configData: ConfigData): String? {
        with(configData) {
            val response = authTokenService.getPartnerToken(
                getPartnerTokenUrl(
                    isExternalPartner,
                    userId,
                    orgId
                )
            )
            logVerbose("Acquired partner token: $response")
            return if (response is NetworkClientProvider.Response.Success) {
                response.data.token
            } else {
                null
            }
        }
    }

    private fun getPartnerTokenUrl(isExternalPartner: Boolean, userId: String, customerId: String): String {
        val uri = PARTNER_TOKEN_URL.replace("{0}", if (isExternalPartner) "p2" else "p1").toUri()

        return uri.buildUpon().appendQueryParameter(KEY_USER_ID, userId)
            .appendQueryParameter(KEY_CUSTOMER_ID, customerId).appendQueryParameter(KEY_SECRET, getCurrentDateString())
            .build().toString()
    }

    private fun getCurrentDateString(): String {
        val current = ZonedDateTime.now(ZoneOffset.UTC)
        val formatter = DateTimeFormatter.ofPattern(DATE_FORMAT)
        return current.format(formatter)
    }

    private fun getSofTokenUrl(emrId: String): String =
        SOF_TOKEN_URL.toUri().buildUpon().appendQueryParameter(KEY_EMR_ID, emrId).build().toString()

    sealed class PartnerAppUiScreenEvent {
        data class AcquireToken(val configData: ConfigData) : PartnerAppUiScreenEvent()
    }

    sealed class PartnerAppUiScreenState {
        data object Idle : PartnerAppUiScreenState()
        data class TokenAcquired(val token: String? = null, val issuer: String? = null, val launch: String? = null) :
            PartnerAppUiScreenState()
    }

    private companion object {
        const val PARTNER_TOKEN_URL = "https://turnkey-token-generator-{0}.azurewebsites.net/api/token/generate"
        const val SOF_TOKEN_URL = "https://ehr-simulator.azurewebsites.net/generateLaunch"
        const val KEY_CUSTOMER_ID = "customerId"
        const val KEY_USER_ID = "userId"
        const val KEY_SECRET = "secret"
        const val KEY_EMR_ID = "emrId"
        const val DATE_FORMAT = "MMddyyyy"
    }
}

data class ConfigData(
    val userId: String,
    val orgId: String,
    val authType: AuthType = AuthType.PARTNER_TOKEN,
    val isExternalPartner: Boolean = false,
)
