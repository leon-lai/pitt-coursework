package edu.pitt.sis.slight;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.hardware.Camera;
import android.hardware.Camera.Parameters;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.os.Handler;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;
public class Overview extends AppCompatActivity {
	/**
	 * The camera object that provides access to the torch.
	 */
	private Camera camera;
	/**
	 * User feedback pane.
	 */
	private TextView textView;
	/**
	 * The threshold below which the camera torch turns on. Its meaning is the
	 * ambient illuminance below which the user would think it is too dark to
	 * see and thus would like the torch to shine. It is initialized to a
	 * reasonable initial value.
	 */
	private float torchOffThresholdIlluminance_lx = (float) 250;
	/**
	 * The current ambient illuminance. It is initialized to the initial
	 * torch-off threshold.
	 */
	private float currentIlluminance_lx = torchOffThresholdIlluminance_lx;
	/**
	 * The inverse of the torch-off threshold update frequency.
	 */
	final private long TORCH_OFF_THRESHOLD_UPDATE_PERIOD_MS = 50;
	/*
	 * THRESHOLD UPDATE LOGIC HAS CHANGED; BELOW TWO FIELDS COMMENTED OUT IN
	 * FAVOR OF TORCH_OFF_THRESHOLD_DELTA_COEFFICIENT.
	 *
	/**
	 * A buffer for storing the last few obtained ambient illuminances. It is
	 * initialized to the initial torch-off threshold. Its size was determined
	 * empirically.
	 *
	private float[] lastFewIlluminances_lx = {
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx, torchOffThresholdIlluminance_lx,
		torchOffThresholdIlluminance_lx
	};
	/**
	 * The index of lastFewIlluminances_lx that indicates the current ambient
	 * illuminance.
	 *
	private int currentIlluminanceIndex = 0;
	 */
	/**
	 * Sets the rate of exponential decay of the torch-off threshold into the
	 * current ambient illuminance (before taking into account the comfort
	 * lower range).
	 */
	final private float TORCH_OFF_THRESHOLD_DELTA_COEFFICIENT = (float) 0.0625;
	/**
	 * The bias for getting the target torch-off threshold.
	 */
	final private float TORCH_OFF_THRESHOLD_ASYMPTOTE_C0_LX = -1;
	/**
	 * The first-order coefficient for getting the target torch-off threshold.
	 */
	final private float TORCH_OFF_THRESHOLD_ASYMPTOTE_C1 = (float) 0.8;
	/**
	 * A value to be added to the torch-off threshold when the button is
	 * pressed.
	 */
	final private float BUTTON_PRESS_TORCH_OFF_THRESHOLD_BOOST_LX = 200;
	/**
	 * Call this method to update the torch state.
	 */
	private void updateTorch () {
		final boolean torchOffThresholdReached =
			currentIlluminance_lx >= torchOffThresholdIlluminance_lx;
		/*
		 * Update user feedback pane.
		 */
		textView.setText(
			"Illuminance = " + currentIlluminance_lx + "lx\nThreshold = " +
				torchOffThresholdIlluminance_lx + " lx\nTorch is " +
				(torchIsOn() ? "on" : "off")
		);
		/*
		 * If illuminance falls below torch-off threshold, shine.
		 */
		final Parameters p = camera.getParameters();
		if (torchOffThresholdReached) {
			p.setFlashMode(Parameters.FLASH_MODE_OFF);
			camera.setParameters(p);
			camera.stopPreview();
		}
		else {
			p.setFlashMode(Parameters.FLASH_MODE_TORCH);
			camera.setParameters(p);
			camera.startPreview();
		}
	}
	private boolean torchIsOn () {
		return Parameters.FLASH_MODE_TORCH.equals(
			camera.getParameters().getFlashMode()
		);
	}
	@Override
	protected void onCreate (Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_overview);
		/*
		 * Get camera.
		 */
		camera = Camera.open();
		/*
		 * Get user feedback pane.
		 */
		textView = (TextView) findViewById(R.id.status);
		/*
		 * Register illuminance change event listener to refresh the current
		 * ambient illuminance variable whenever the light sensor detects a
		 * change in the actual ambient illuminance.
		 */
		final SensorManager SENSOR_MANAGER = (SensorManager) getSystemService(
			Context.SENSOR_SERVICE
		);
		SENSOR_MANAGER.registerListener(
			new SensorEventListener() {
				/**
				 * This method is called whenever the light sensor's detected
				 * value changes.
				 */
				@Override
				public void onSensorChanged (SensorEvent event) {
					/*
					 * Updated store current illuminance value.
					 */
					currentIlluminance_lx = event.values[0];
					/*
					 * Update torch state.
					 */
					updateTorch();
				}
				@Override
				public void onAccuracyChanged (Sensor sensor, int accuracy) {
				}
			},
			SENSOR_MANAGER.getDefaultSensor(Sensor.TYPE_LIGHT),
			SENSOR_MANAGER.SENSOR_DELAY_NORMAL
		);
		/*
		 * Create timer to update the torch-off threshold based on the current
		 * ambient illuminance and itself periodically.
		 */
		final Handler TIMED_HANDLER = new Handler();
		TIMED_HANDLER.postDelayed(
			new Runnable() {
				/*
				 * This method will be called periodically.
				 */
				@Override
				public void run () {
					/*
					 * Update torch-off threshold.
					 */
					final float torchOffThresholdTarget =
						TORCH_OFF_THRESHOLD_ASYMPTOTE_C1 * currentIlluminance_lx +
							TORCH_OFF_THRESHOLD_ASYMPTOTE_C0_LX;
					torchOffThresholdIlluminance_lx +=
						TORCH_OFF_THRESHOLD_DELTA_COEFFICIENT *
							(torchOffThresholdTarget -
								torchOffThresholdIlluminance_lx);
					/*
					 * Update torch state.
					 */
					updateTorch();
					/*
					 * Run this method again after a threshold update period has
					 * passed.
					 */
					TIMED_HANDLER.postDelayed(
						this, TORCH_OFF_THRESHOLD_UPDATE_PERIOD_MS
					);
				}
			}, 0
		);
		/*
		 * Register button press event listener to bump up the torch-off
		 * threshold and to change the button's appearance whenever the button
		 * is pressed.
		 */
		final Button BUTTON = (Button) findViewById(R.id.button);
		final int BUTTON_BACKGROUND_COLOR =
			((ColorDrawable) BUTTON.getBackground()).getColor();
		final int BUTTON_FOREGROUND_COLOR = BUTTON.getCurrentTextColor();
		BUTTON.setOnTouchListener(
			new View.OnTouchListener() {
				/*
				 * This method will be called whenever the button is pressed or
				 * whenever the button press is released.
				 */
				@Override
				public boolean onTouch (View v, MotionEvent event) {
					switch (event.getAction()) {
						/*
						 * When the button is pressed.
						 */
						case MotionEvent.ACTION_DOWN:
							/*
							 * Boost torch-off threshold.
							 */
							torchOffThresholdIlluminance_lx = currentIlluminance_lx +
								BUTTON_PRESS_TORCH_OFF_THRESHOLD_BOOST_LX;
							/*
							 * Invert button's colors.
							 */
							BUTTON.setBackgroundColor(BUTTON_FOREGROUND_COLOR);
							BUTTON.setTextColor(BUTTON_BACKGROUND_COLOR);
							return true;
						/*
						 * When the button press is released.
						 */
						case MotionEvent.ACTION_UP:
							/*
							 * Revert button's colors.
							 */
							BUTTON.setBackgroundColor(BUTTON_BACKGROUND_COLOR);
							BUTTON.setTextColor(BUTTON_FOREGROUND_COLOR);
							return true;
						default:
							return false;
					}
				}
			}
		);
	}
	/* Since now onStart only calls super's onStart, it can be gone altogether.
	@Override
	protected void onStart () {
		super.onStart();
	}
	 */
	/* Since now onStop only calls super's onStop, it can be gone altogether.
	@Override
	protected void onStop () {
		super.onStop();
		/*
		 * The below statement must be commented out for the camera torch to
		 * remain accessible when the app runs in the background.
		 *
		//camera.release();
	}
	*/
	@Override
	public boolean onCreateOptionsMenu (Menu menu) {
		/*
		 * Inflate the menu; this adds items to the action bar if it is present.
		 */
		getMenuInflater().inflate(R.menu.menu_main, menu);
		/*
		 * Must return true for the menu to be displayed.
		 */
		return true;
	}
	@Override
	public boolean onOptionsItemSelected (MenuItem item) {
		/*
		 * No need to process item's id because there is only one item in the
		 * menu.
		 */
		System.exit(0);
		return super.onOptionsItemSelected(item);
	}
}
