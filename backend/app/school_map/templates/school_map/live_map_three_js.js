{% load btss_extras %}
import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(
  75,
  window.innerWidth / window.innerHeight,
  0.1,
  1000
);
const renderer = new THREE.WebGLRenderer({ alpha: true });
renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setClearColor(0xffffff, 0);
document
  .getElementById("btss-three-js-container")
  .appendChild(renderer.domElement);

const controls = new OrbitControls(camera, renderer.domElement);
controls.mouseButtons = {
  LEFT: THREE.MOUSE.PAN,
  MIDDLE: THREE.MOUSE.DOLLY,
  RIGHT: THREE.MOUSE.ROTATE,
};
controls.touches = {
  ONE: THREE.TOUCH.PAN,
  TWO: THREE.TOUCH.DOLLY_ROTATE,
};
controls.screenSpacePanning = true;
controls.minDistance = 1;
controls.maxDistance = {{ max_camera_height }};
controls.maxPolarAngle = Math.PI / 4;

camera.position.y = {{ default_camera_height }};
camera.lookAt(new THREE.Vector3(0, 0, 0));

const loader = new GLTFLoader();
var schoolMap;

loader.load(
  {{ map_file_path|quote }},
  (gltf) => {
    schoolMap = gltf.scene.children[0];
    schoolMap.material = new THREE.MeshBasicMaterial({
      color: 0xbbdede,
      side: THREE.DoubleSide,
    });
    scene.add(schoolMap);
    animate();
  },
  undefined,
  function (error) {
    console.error(error);
  }
);

function animate() {
  requestAnimationFrame(animate);
  renderer.render(scene, camera);
}
