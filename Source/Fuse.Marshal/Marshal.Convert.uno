using Uno;
using Uno.UX;
using Uno.Collections;

namespace Fuse
{
	public static partial class Marshal
	{
		public interface IConverter
		{
			bool CanConvert(Type t);
			object TryConvert(Type t, object o);
		}

		static List<IConverter> _converters = new List<IConverter>();
		public static void AddConverter(IConverter conv)
		{
			_converters.Add(conv);
		}

		/**
			Be aware that this returns `true` if the input is null.
		*/
		public static bool TryConvertTo(Type t, object o, out object res, object diagnosticSource = null)
		{
			if (o == null) 
			{
				res = null;
				return true;
			}

			if (t == typeof(double)) { res = ToDouble(o); return true; }
			else if (t == typeof(string)) { res = o.ToString(); return true; }
			else if (t == typeof(Selector)) { res = (Selector)o.ToString(); return true; }
			else if (t == typeof(float)) { res = ToFloat(o); return true; }
			else if (t == typeof(int)) { res = ToInt(o); return true; }
			else if (t == typeof(bool)) { res = ToBool(o); return true; }
			else if (t == typeof(Size)) { res = ToSize(o); return true; }
			else if (t == typeof(Size2)) { res = ToSize2(o); return true; }
			else if (t == typeof(float2)) { res = ToFloat2(o); return true; }
			else if (t == typeof(float3)) { res = ToFloat3(o); return true; }
			else if (t == typeof(float4)) { res = ToFloat4(o); return true; }
			else if (t.IsEnum && o is string) { res = Uno.Enum.Parse(t, (string)o); return true; }
			else
			{
				for (int i = 0; i < _converters.Count; i++)
				{
					var c = _converters[i].TryConvert(t, o);
					if (c != null) 
					{
						res = c;
						return true;
					}
				}
			}

			if (diagnosticSource != null)
				Diagnostics.UserError("Cannot convert '" + o + "' to target type '" + t + "'", diagnosticSource);

			res = null;
			return false;
		}

		/**
			Be aware this function may throw a NullReferenceException if the type cannot be converted to the desired one. It is advised to use TryToType or TryConvertTo instead.
		*/
		public static T ToType<T>(object o)
		{
			object res;
			TryConvertTo(typeof(T), o, out res);
			return (T)res;
		}

		/**
			Tries to convert to a target value. Unlike `TryConvertTo` this will return `false` if the input value is `null`.
		*/
		public static bool TryToType<T>(object o, out T res)
		{
			object ores;
			if (!TryConvertTo(typeof(T), o, out ores) || ores == null)
			{
				res = default(T);
				return false;
			}
			res = (T)ores;
			return true;
		}
		
		public static bool CanConvertClass(Type t)
		{
			for (int i = 0; i < _converters.Count; i++)
			{
				if (_converters[i].CanConvert(t)) return true;
			}
			return false;
		}
	}
}