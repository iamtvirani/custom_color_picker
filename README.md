   <h1>Circle Color Picker App</h1>
        <p>A Flutter application featuring a circular color picker with customizable lightness and hue controls. Users can visually select a color, and the selected color dynamically updates the UI.</p>
    </header>
    <section>
        <h2>Features</h2>
        <ul>
            <li><strong>Circular Hue Picker:</strong> Intuitive wheel-based hue selection.</li>
            <li><strong>Vertical Lightness Slider:</strong> Adjust the lightness of the selected hue.</li>
            <li><strong>Real-Time Color Display:</strong> Updates UI with the selected color.</li>
            <li><strong>Customizable Components:</strong> Easily configure the picker dimensions, thumb size, and stroke width.</li>
        </ul>
    </section>
    <section>
        <h2>Getting Started</h2>
        <h3>Prerequisites</h3>
        <p>Ensure you have:</p>
        <ol>
            <li><a href="https://flutter.dev/docs/get-started/install" target="_blank">Flutter SDK</a> installed.</li>
            <li>A compatible editor like Visual Studio Code or Android Studio.</li>
        </ol>
        <h3>Installation</h3>
        <pre class="code-block">
git clone &lt;repository_url&gt;
cd &lt;project_folder&gt;
flutter pub get
flutter run
        </pre>
    </section>
    <section>
        <h2>How It Works</h2>
        <h3>Color Picker Components</h3>
        <ul>
            <li><strong>CircleColorPicker:</strong> Displays a circular hue picker and interacts with the lightness slider.</li>
            <li><strong>LightnessSlider:</strong> Adjusts the lightness of the selected hue using vertical drag gestures.</li>
        </ul>
        <h3>State Management</h3>
        <p><strong>I'm not using any perticular state management.
if you want to use than you can add it self</strong> </p>
    </section>
    <section>
        <h2>Usage</h2>
        <h3>Customization</h3>
        <table>
            <thead>
                <tr>
                    <th>Property</th>
                    <th>Type</th>
                    <th>Description</th>
                    <th>Default Value</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td><code>size</code></td>
                    <td><code>Size</code></td>
                    <td>Picker dimensions (width, height).</td>
                    <td><code>Size(280, 280)</code></td>
                </tr>
                <tr>
                    <td><code>strokeWidth</code></td>
                    <td><code>double</code></td>
                    <td>Thickness of the color wheel.</td>
                    <td><code>13.0</code></td>
                </tr>
                <tr>
                    <td><code>thumbSize</code></td>
                    <td><code>double</code></td>
                    <td>Diameter of the thumb indicator.</td>
                    <td><code>32.0</code></td>
                </tr>
                <tr>
                    <td><code>controller</code></td>
                    <td><code>CircleColorPickerController?</code></td>
                    <td>Tracks and updates selected color.</td>
                    <td><code>null</code></td>
                </tr>
                <tr>
                    <td><code>onChanged</code></td>
                    <td><code>ValueChanged&lt;Color&gt;?</code></td>
                    <td>Callback for color change event.</td>
                    <td><code>null</code></td>
                </tr>
            </tbody>
        </table>
