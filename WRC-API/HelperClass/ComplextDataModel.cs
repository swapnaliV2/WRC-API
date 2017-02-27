using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WRC_API.HelperClass
{
    public class ComplexDataModel
    {
        public ComplexDataModel(Type objectType, object objectData)
        {
            ObjectType = objectType;
            ObjectData = objectData;
        }
        public Type ObjectType { get; set; }

        public object ObjectData { get; set; }
    }
}