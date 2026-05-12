package com.microsoft.dragoncopilot.sampleapp

import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.view.ViewGroup
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.systemBarsPadding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.viewinterop.AndroidView
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.microsoft.dragoncopilot.sampleapp.network.AuthTokenServiceImpl
import com.microsoft.dragoncopilot.sampleapp.ui.theme.DependencyTestAppTheme
import com.microsoft.dragoncopilot.turnkey.AppUiComponent
import com.microsoft.dragoncopilot.turnkey.ApplicationConfig
import com.microsoft.dragoncopilot.turnkey.logging.Logger.logInfo
import com.microsoft.dragoncopilot.turnkey.model.ClientTokenProvider
import com.microsoft.dragoncopilot.turnkey.model.input.ApplicationConfigProvider
import com.microsoft.dragoncopilot.turnkey.model.input.AuthType
import com.microsoft.dragoncopilot.turnkey.model.input.ClientAppInfo
import com.microsoft.dragoncopilot.turnkey.model.input.Environment
import com.microsoft.dragoncopilot.turnkey.model.input.ServerInfo
import com.microsoft.dragoncopilot.turnkey.model.input.UserInfo
import com.microsoft.dragoncopilot.turnkey.model.input.VisitInfo
import java.util.UUID

class MainActivity : ComponentActivity() {
    private val configData by lazy { ConfigData(USER_ID, ORG_ID) }

    private val mainActivityViewModel: MainActivityViewModel by viewModels {
        object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return MainActivityViewModel(
                    configData = configData,
                    authTokenService = AuthTokenServiceImpl()
                ) as T
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            DependencyTestAppTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { padding ->
                    DragonUiView(
                        configData = configData,
                        viewModel = mainActivityViewModel,
                        modifier = Modifier.padding(padding)
                    )
                }
            }
        }
    }

    companion object {
        const val ORG_ID = "" // add your orgId or customerId
        const val USER_ID = "" // add your userId
        const val PARTNER_ID = "" // add your partnerId
    }
}

@Composable
fun DragonUiView(configData: ConfigData, viewModel: MainActivityViewModel, modifier: Modifier) {
    var permissionResult by remember { mutableStateOf<((Map<String, Boolean>) -> Unit)?>(null) }
    var tokenResult by remember { mutableStateOf<((ClientTokenProvider) -> Unit)?>(null) }
    var turnkeySession : ApplicationConfig? = null
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions(),
        onResult = { result ->
            permissionResult?.invoke(result)
            permissionResult = null
        }
    )

    LaunchedEffect(Unit) {
        viewModel.uiState.collect { state ->
            when (state) {
                is MainActivityViewModel.PartnerAppUiScreenState.TokenAcquired -> {
                    if (configData.authType == AuthType.PARTNER_TOKEN) {
                        logInfo("Acquired partner token, passing to Turnkey")
                        tokenResult?.invoke(
                            ClientTokenProvider.ClientToken(
                                state.token
                            )
                        )
                    } else if (configData.authType == AuthType.SMART_ON_FHIR) {
                        logInfo("Acquired SoF token, passing to Turnkey")
                        tokenResult?.invoke(
                            ClientTokenProvider.ClientSoFToken(
                                issuer = state.issuer,
                                launch = state.launch
                            )
                        )
                    }
                    tokenResult?.invoke(ClientTokenProvider.ClientToken(state.token))
                }

                else -> {
                    // do nothing
                }
            }
        }
    }
    AndroidView(factory = { context ->
        val turnkeyUiComponent = AppUiComponent(context).apply {
            val appMetadata = ClientAppInfo(
                appId = context.packageName,
                appVersion = context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "1.0",
                deviceId = Settings.Secure.getString(context.contentResolver, Settings.Secure.ANDROID_ID)
            )

            turnkeySession =
                ApplicationConfig.getInstance(
                    applicationUiComponent = this,
                    applicationConfigProvider = ApplicationConfigProvider(
                        clientAppInfo = appMetadata,
                        serverInfo = ServerInfo(
                            environment = Environment.PROD,
                            geography = "US"
                        ),
                        providerName = context.getString(R.string.app_name),
                        customerId = MainActivity.ORG_ID,
                        partnerId = MainActivity.PARTNER_ID,
                        authType = AuthType.PARTNER_TOKEN,
                        userInfo = UserInfo(ehrUserId = MainActivity.USER_ID),
                    ),
                    checkPermission = { permissionsToRequest, onPermissionResult ->
                        val status = permissionsToRequest.associateWith { permission ->
                            ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED
                        }
                        val need = status.filterValues { !it }.keys
                        if (need.isEmpty()) {
                            onPermissionResult(status)
                        } else {
                            permissionResult = onPermissionResult
                            permissionLauncher.launch(need.toTypedArray())
                        }
                    },
                    acquireNewTokenListener = { scopes, isForceRefresh, onSuccess, onFailure ->
                        tokenResult = onSuccess
                        viewModel.onEvent(
                            MainActivityViewModel.PartnerAppUiScreenEvent.AcquireToken(
                                configData
                            )
                        )
                    }
                )

            turnkeySession.openSession(visitInfo = VisitInfo(
                correlationId = UUID.randomUUID().toString() // Partner-defined correlation ID
            ))
        } as ViewGroup
        turnkeyUiComponent
    }, modifier = Modifier.fillMaxSize().systemBarsPadding())

    DisposableEffect(Unit) {
        onDispose {
            // Clean up if needed
            turnkeySession?.closeSession()
            ApplicationConfig.clearInstance()
        }
    }

}