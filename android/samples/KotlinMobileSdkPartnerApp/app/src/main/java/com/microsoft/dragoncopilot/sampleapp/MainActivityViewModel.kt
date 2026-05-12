/*
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 */

package com.microsoft.dragoncopilot.sampleapp

import androidx.lifecycle.ViewModel
import com.microsoft.dragoncopilot.sampleapp.network.AuthTokenService
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logVerbose
import com.microsoft.dragoncopilot.turnkey.model.input.AuthType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

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
                        // Get Smart on FHIR details and pass to SDK
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
            return ""
        }
    }

    sealed class PartnerAppUiScreenEvent {
        data class AcquireToken(val configData: ConfigData) : PartnerAppUiScreenEvent()
    }

    sealed class PartnerAppUiScreenState {
        data object Idle : PartnerAppUiScreenState()
        data class TokenAcquired(val token: String? = null, val issuer: String? = null, val launch: String? = null) :
            PartnerAppUiScreenState()
    }
}

data class ConfigData(
    val userId: String,
    val orgId: String,
    val authType: AuthType = AuthType.PARTNER_TOKEN,
    val isExternalPartner: Boolean = false,
)
