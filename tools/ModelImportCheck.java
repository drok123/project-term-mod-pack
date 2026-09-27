import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

/** Read-only native model import using the installed game's Jassimp library. */
public class ModelImportCheck {
    public static void main(String[] args) throws Exception {
        Path game = Path.of(args[0]).toAbsolutePath();
        Class<?> jassimp = Class.forName("jassimp.Jassimp");
        Class.forName("zombie.core.skinnedmodel.model.jassimp.JAssImpImporter")
            .getMethod("Init").invoke(null);
        Class<?> step = Class.forName("jassimp.AiPostProcessSteps");
        Set<Object> flags = new HashSet<>();
        for (String name : new String[]{"FIND_INSTANCES", "MAKE_LEFT_HANDED", "LIMIT_BONE_WEIGHTS",
                "TRIANGULATE", "OPTIMIZE_MESHES", "REMOVE_REDUNDANT_MATERIALS", "JOIN_IDENTICAL_VERTICES"}) {
            flags.add(step.getField(name).get(null));
        }
        for (int file = 1; file < args.length; file++) {
            Object scene = jassimp.getMethod("importFile", String.class, Set.class)
                .invoke(null, Path.of(args[file]).toAbsolutePath().toString(), flags);
            List<?> meshes = (List<?>) scene.getClass().getMethod("getMeshes").invoke(scene);
            int vertices = 0, faces = 0;
            for (Object mesh : meshes) {
                vertices += (Integer) mesh.getClass().getMethod("getNumVertices").invoke(mesh);
                faces += (Integer) mesh.getClass().getMethod("getNumFaces").invoke(mesh);
            }
            System.out.println(Path.of(args[file]).getFileName() + " meshes=" + meshes.size() + " vertices=" + vertices + " triangles=" + faces);
        }
    }
}
