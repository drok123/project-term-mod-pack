import java.nio.file.*;
public class LuaTestRunner {
 public static void main(String[] args) throws Exception {
  Class<?> p=Class.forName("se.krka.kahlua.vm.Platform"), t=Class.forName("se.krka.kahlua.vm.KahluaTable");
  Object platform=Class.forName("se.krka.kahlua.j2se.J2SEPlatform").getConstructor().newInstance();
  Object env=platform.getClass().getMethod("newEnvironment").invoke(platform);
  Class<?> tc=Class.forName("se.krka.kahlua.vm.KahluaThread");
  Object thread=tc.getConstructor(p,t).newInstance(platform,env);
  var owner=tc.getDeclaredField("debugOwnerThread"); owner.setAccessible(true); owner.set(thread,Thread.currentThread());
  var loader=Class.forName("se.krka.kahlua.luaj.compiler.LuaCompiler").getMethod("loadstring",String.class,String.class,t);
  for(String file:args) {
   Object chunk=loader.invoke(null,Files.readString(Path.of(file)),file,env);
   Object[] result=(Object[])tc.getMethod("pcall",Object.class,Object[].class).invoke(thread,chunk,new Object[0]);
   if(!Boolean.TRUE.equals(result[0])) throw new AssertionError(java.util.Arrays.toString(result));
  }
  System.out.println("Kahlua tests passed");
 }
}


