import React, { useEffect, useState } from 'react';
import { Button, NativeModules, requireNativeComponent, StyleSheet, View } from 'react-native';
import { PERMISSIONS, request, RESULTS } from 'react-native-permissions';
const { DRCBridgeModule } = NativeModules;

const DRCView = requireNativeComponent('DRCView');

const ContentView = () => {
  const [sessionOpened, setSessionOpened] = useState(false);
  const [turnkeyInitialized, setTurnkeyInitialized] = useState(false);

  useEffect(() => {
    async function setupPermissions() {
      await requestPermissions();
    }
    setupPermissions();
  }, []);

  const initializeTurnkey = () => {
    if (!turnkeyInitialized) {
      DRCBridgeModule.initTurnkeySdk();
      setTurnkeyInitialized(true);
    }
    setSessionOpened(true);
  };

  const handleLayout = (event) => {
    const { height } = event.nativeEvent.layout;
    if (height < 100) { // Adjust the threshold as needed
      setSessionOpened(false);
    }
  };

  async function requestPermissions() {
    const audioPermission = await request(PERMISSIONS.IOS.MICROPHONE);
    if (audioPermission === RESULTS.GRANTED) {
      console.log('You can use the audio recording in the background');
    } else {
      console.log('Permission denied');
    }
  }

  useEffect(() => {
    if (sessionOpened) {
      DRCBridgeModule.openSession();
    }
  }, [sessionOpened]);

  return (
    <View style={styles.container}>
      {!sessionOpened && (
        <Button title="Load Session" onPress={initializeTurnkey} />
      )}
      {sessionOpened && (
        <View style={styles.drcViewContainer} onLayout={handleLayout}>
          <DRCView style={styles.drcView} />
        </View>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
    width: '100%',
    height: '100%',
  },
  drcViewContainer: {
    flex: 1,
    width: '100%',
    height: '100%',
    justifyContent: 'center',
    alignItems: 'center',
  },
  drcView: {
    flex: 1,
    width: '100%',
    height: '100%',
  },
});

export default ContentView;